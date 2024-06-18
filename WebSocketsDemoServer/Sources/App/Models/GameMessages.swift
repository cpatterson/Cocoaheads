import Foundation

enum ServerGameMessage: Codable {
    case waitingForPlayer
    case yourTurn
    case opponentsTurn
    case moveAccepted(TicTacToe.Board, TicTacToe.GameState)
    case moveRejected
    case opponentMoved(TicTacToe.Board, TicTacToe.GameState)
    case youLeft(TicTacToe.GameState)
    case opponentLeft(TicTacToe.GameState)

    var moveWasRejected: Bool {
        if case .moveRejected = self { true } else { false }
    }
}

enum ClientGameMessage: Codable {
    case move(GameMove)
    case joinGame
    case leaveGame
}

