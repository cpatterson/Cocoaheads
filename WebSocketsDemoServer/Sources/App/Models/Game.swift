import Foundation
import WS

struct User: Equatable {
    let name: String
    let clientID: UUID
}

struct GameMove: Codable {
    let row: Int
    let col: Int
    let player: TicTacToe.Player // X or O
}

struct Game {
    let playerX: User
    var playerO: User?
    let state: TicTacToe

    init(playerX: User) {
        self.playerX = playerX
        self.playerO = nil
        self.state = TicTacToe()
    }
}

extension Game {
    var players: [User] {
        if let playerO { [playerX, playerO] } else { [playerX] }
    }

    var needsPlayer: Bool { playerO == nil }

    func contains(_ player: User) -> Bool {
        players.contains(player)
    }

    func makeMove(_ player: User, move: GameMove) -> (ServerGameMessage, ServerGameMessage?) {
        let allowed = state.makeMove(row: move.row, col: move.col, player: move.player)
        if !allowed {
            print("**\(player.name)**'s move rejected")
            return (
                .moveRejected,
                nil
            )
        }
        print("**\(player.name)** placed an \(move.player.rawValue.uppercased()) on (\(move.row), \(move.col))")
        let outcome = state.checkWin()
        return (
            .moveAccepted(state.board, outcome),
            .opponentMoved(state.board, outcome)
        )
    }

    func leave(_ player: User, _ client: AnyClient) -> TicTacToe.GameState? {
        guard players.contains(player) else { return nil }
        let side: TicTacToe.Player = (player == playerX) ? .x : .o
        let outcome = state.leave(player: side)
        var message: String?
        switch outcome {
        case .ongoing:
            message = "**\(player.name)**'s game is ongoing (should not happen after player leaves?)"
        case .draw:
            message = "**\(player.name)**'s game ends in a draw"
        case let .win(side):
            if let winner = (side == .x) ? playerX : playerO {
                message = "**\(winner.name)** wins!"
            }
        }
        if let message {
            _ = client.broadcast.channels("game").send(text: message)
            print(message)
        }
        return outcome
    }
}

