import SwiftUI

struct GameView: View {
    var body: some View {
        NavigationView {
            VStack {
                Divider()
                Text("Tic-Tac-Toe")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Tic-Tac-Toe")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GameView()
}
