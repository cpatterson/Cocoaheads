import Foundation
import WS

extension WSID {
    static var demoGame: WSID<DemoGame> { .init() }
}

extension AnyClient {
    func send(_ gameMessage: ServerGameMessage) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(gameMessage) else { return }
        send(data: data)
    }
}

class DemoGame: ClassicObserver {
    enum Constants {
        static let defaultName = "Anonymous"
    }

    var players = [UUID: User]()
    var games = [Game]()

    override func on(open client: AnyClient) {
        let name = client.originalRequest.parameters.get("name") ?? Constants.defaultName
        let player = User(name: name, clientID: client.id)
        players[client.id] = player

//        client.subscribe(to: "game", on: eventLoop)

        joinGame(player, client)
    }

    override func on(close client: AnyClient) {
        guard let player = players[client.id] else { return }

        leaveGame(player, client)

//        client.unsubscribe(from: "game", on: eventLoop)
        players.removeValue(forKey: client.id)
    }

    override func on(text: String, client: any AnyClient) {
        guard let data = text.data(using: .utf8) else { return }
        on(data: data, client: client)
    }

    override func on(data: Data, client: any AnyClient) {
        guard let player = players[client.id] else { return }

        do {
            let decoder = JSONDecoder()
            let gameMessage = try decoder.decode(ClientGameMessage.self, from: data)
            switch gameMessage {
            case let .move(gameMove):
                guard let game = games.first(where: { $0.contains(player) }) else {
                    client.send(.moveRejected)
                    return
                }
                handleMove(gameMove, game, player, client)
            case .joinGame:
                joinGame(player, client)
            case .leaveGame:
                leaveGame(player, client)
            }
        } catch {
            print(
                """
                *Error decoding game message: \(error.localizedDescription)*
                Game message:
                  \(String(data: data, encoding: .utf8) ?? data.debugDescription)
                """
            )
        }
    }
}

extension DemoGame {
    func pendingGame(_ player: User) -> Game? {
        if let index = games.firstIndex(where: { $0.needsPlayer && $0.playerX != player }) {
            var game = games[index]
            game.playerO = player
            games[index] = game
            return game
        }
        return nil
    }

    func newGame(_ player: User) -> Game {
        let game = Game(playerX: player)
        games.append(game)
        return game
    }

    func joinGame(
        _ player: User,
        _ client: any AnyClient
    ) {
        let name = player.name

        // Find first game waiting on second player or start new game
        let game = pendingGame(player) ?? newGame(player)

        _ = client.broadcast.channels("game").send(text: "**\(name)** has joined a game")
        print("**\(name)** has joined a game")

        if game.needsPlayer {
            print("**\(name)** is waiting on second player")
            client.send(.waitingForPlayer)
        } else {
            print("**\(name)** is playing **\(game.playerX.name)**")
            print("Game board:")
            game.state.printBoard()
            print("**\(game.playerX.name)**'s turn")
            client.send(.opponentsTurn)
            if let opponentClient = clients.first(where: { $0.id == game.playerX.clientID }) {
                opponentClient.send(.yourTurn)
            }
        }
    }

    func leaveGame(
        _ player: User,
        _ client: any AnyClient
    ) {
        _ = client.broadcast.channels("game").send(text: "**\(player.name)** has left a game")
        print("**\(player.name)** has left a game")

        if let game = games.first(where: { $0.contains(player) }) {
            print("Game board:")
            game.state.printBoard()
            if let outcome = game.leave(player, client) {
                client.send(.youLeft(outcome))
                if
                    let opponent = game.players.first(where: { $0.clientID != player.clientID }),
                    let opponentClient = clients.first(where: { $0.id == opponent.clientID }) {
                    opponentClient.send(.opponentLeft(outcome))
                }
            }
        }
        games.removeAll(where: { $0.contains(player) })
    }

    func handleMove(
        _ gameMove: GameMove,
        _ game: Game,
        _ player: User,
        _ client: AnyClient
    ) {
        let playerMessages = game.makeMove(player, move: gameMove)
        print("Game board:")
        game.state.printBoard()

        let outcome = game.state.checkWin()
        var message: String?
        switch outcome {
        case .ongoing:
            break
        case .draw:
            message = "**\(player.name)**'s game ends in a draw"
        case let .win(side):
            if let winner = (side == .x) ? game.playerX : game.playerO {
                message = "**\(winner.name)** wins!"
            }
        }
        if let message {
            _ = client.broadcast.channels("game").send(text: message)
            print(message)
        }

        client.send(playerMessages.0)
        if !outcome.hasEnded && !playerMessages.0.moveWasRejected {
            client.send(.opponentsTurn)
        }

        if
            let opponentMessage = playerMessages.1,
            let opponent = game.players.first(where: { $0.clientID != player.clientID }),
            let opponentClient = clients.first(where: { $0.id == opponent.clientID }) {
            opponentClient.send(opponentMessage)
            if !outcome.hasEnded {
                opponentClient.send(.yourTurn)
            }
        }
    }
}
