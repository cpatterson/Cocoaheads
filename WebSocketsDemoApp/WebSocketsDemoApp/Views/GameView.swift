import SwiftUI

struct GameView: View {
    enum Constants {
        static let emptyGameBoard: [[TicTacToe.Player]] = Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }
    @Binding var name: String?
    @State var gameBoard: [[TicTacToe.Player]] = Constants.emptyGameBoard
    @State var connection: WebSocketConnection?
    @State var isVisible = false
    @State var boardIsEnabled = false
    @State var messageText = "Message"
    @State var gameStateText = " "
    @State var yourPlayer: TicTacToe.Player = .none
    @State var canJoin = false
    @State var canLeave = true

    var gameURL: URL? {
        guard let name else { return nil }
        return URL(string: "ws://vision.local:8080/game/\(name)")!
    }

    var body: some View {
        NavigationView {
            VStack {
                Divider()
                VStack {
                    Text(messageText)
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.mint)
                    Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                        ForEach(0..<3) { row in
                            GridRow {
                                ForEach(0..<3) { col in
                                    TicTacToeCell(player: gameBoard[row][col])
                                        .onTapGesture {
                                            sendMove(GameMove(row: row, col: col, player: yourPlayer))
                                        }
                                }
                            }
                            .frame(height: 117)
                            .border(Color.secondary)
                        }
                    }
                    .background(Color.mint.opacity(0.1))
                    .padding(10)
                    .border(Color.mint.opacity(0.1), width: 10)
                    .allowsHitTesting(boardIsEnabled)
                    .opacity(boardIsEnabled ? 1.0 : 0.5)
                    Text(gameStateText)
                        .font(.title)
                    HStack(spacing: 20) {
                        Button {
                            leaveGame()
                        } label: {
                            Label {
                                Text("Leave Game")
                            } icon: {
                                Image(systemName: "figure.walk.departure")
                            }
                        }
                        .disabled(!canLeave)
                        Button {
                            joinGame()
                        } label: {
                            Label {
                                Text("New Game")
                            } icon: {
                                Image(systemName: "grid.circle")
                            }
                        }
                        .disabled(!canJoin)
                    }
                    .buttonBorderShape(.capsule)
                    .padding()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Tic-Tac-Toe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            name = nil
                        },
                        label: {
                            Text("Sign Out")
                        }
                    )
                }
            }
        }
        .onAppear {
            isVisible = true
            connect()
        }
        .onDisappear {
            isVisible = false
            disconnect()
        }
        .onChange(of: name) {
            if isVisible {
                connect()
            }
        }
    }

    func connect() {
        guard let gameURL else { return }
        connection = WebSocketConnection.connect(url: gameURL, objectReceived: { (message: ServerGameMessage) in
            debugPrint("Received game message: " + String(describing: message))
            handleGameMessage(message)
        })
    }

    func disconnect() {
        connection?.close()
        connection = nil
    }

    func handleGameMessage(_ message: ServerGameMessage) {
        switch message {
        case .waitingForPlayer:
            messageText = "Waiting for Opponent..."
            boardIsEnabled = false
            yourPlayer = .x
            gameBoard = Constants.emptyGameBoard
            canLeave = true
            canJoin = false

        case .yourTurn:
            messageText = "Your Turn"
            boardIsEnabled = true
            if yourPlayer == .none {
                yourPlayer = .x
            }
            canLeave = true
            canJoin = false

        case .opponentsTurn:
            messageText = "Opponent's Turn"
            boardIsEnabled = false
            if yourPlayer == .none {
                yourPlayer = .o
            }
            canLeave = true
            canJoin = false

        case let .moveAccepted(board, gameState):
            gameBoard = board
            checkGameState(gameState)

        case .moveRejected:
            messageText = "Invalid Move"
            gameStateText = "Try again..."
            boardIsEnabled = true

        case let .opponentMoved(board, gameState):
            gameBoard = board
            checkGameState(gameState)

        case let .youLeft(gameState):
            messageText = "Game Ended"
            boardIsEnabled = false
            checkGameState(gameState)

        case let .opponentLeft(gameState):
            messageText = "Game Ended"
            boardIsEnabled = false
            checkGameState(gameState)
        }
    }

    func checkGameState(_ gameState: TicTacToe.GameState) {
        switch gameState {
        case .ongoing:
            gameStateText = " "
            canLeave = true
            canJoin = false
        case .draw:
            gameStateText = "Game ended in a draw"
            canLeave = false
            canJoin = true
        case let .win(player):
            if player == yourPlayer {
                gameStateText = "🎉 You win!"
            } else {
                gameStateText = "🤦‍♂️ You lose"
            }
            canLeave = false
            canJoin = true
        }
    }

    func sendMove(_ move: GameMove) {
        connection?.send(object: ClientGameMessage.move(move))
    }

    func leaveGame() {
        connection?.send(object: ClientGameMessage.leaveGame)
        messageText = "Game Ended"
        gameStateText = "You left the game"
        canLeave = false
        canJoin = true
    }

    func joinGame() {
        connection?.send(object: ClientGameMessage.joinGame)
        gameStateText = " "
        canLeave = true
        canJoin = false
    }
}

#Preview {
    GameView(name: Binding(get: { "Chris" }, set: { _ in }))
}
