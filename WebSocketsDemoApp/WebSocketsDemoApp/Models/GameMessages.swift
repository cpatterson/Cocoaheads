import Foundation

final class TicTacToe: Codable {
    typealias Board = [[Player]]

    enum Player: String, Codable {
        case none
        case x
        case o
    }

    enum GameState: Codable {
        case ongoing
        case draw
        case win(Player)

        func didWin(_ player: Player) -> Bool {
            if case let .win(side) = self {
                return side == player
            }
            return false
        }

        var didDraw: Bool {
            if case .draw = self { true } else { false }
        }

        var hasEnded: Bool {
            if case .ongoing = self { false } else { true }
        }
    }
}

struct GameMove: Codable {
    let row: Int
    let col: Int
    let player: TicTacToe.Player // X or O
}

enum ServerGameMessage: Codable {
    case waitingForPlayer
    case yourTurn
    case opponentsTurn
    case moveAccepted(TicTacToe.Board, TicTacToe.GameState)
    case moveRejected
    case opponentMoved(TicTacToe.Board, TicTacToe.GameState)
    case youLeft(TicTacToe.GameState)
    case opponentLeft(TicTacToe.GameState)
}

enum ClientGameMessage: Codable {
    case move(GameMove)
    case joinGame
    case leaveGame
}

