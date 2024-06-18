import SwiftUI

struct TicTacToeCell: View {
    var player: TicTacToe.Player

    var body: some View {
        VStack {
            switch player {
            case .none:
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()

            case .x:
                Image(systemName: "xmark")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .foregroundStyle(Color.red)

            case .o:
                Image(systemName: "circle")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .foregroundStyle(Color.blue)
            }
        }
        .background {
            Color.white
        }
    }
}
