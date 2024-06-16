import SwiftUI

struct GameView: View {
    @Binding var name: String?

    var body: some View {
        NavigationView {
            VStack {
                Divider()
                Text("Tic-Tac-Toe")
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
    }
}

#Preview {
    GameView(name: Binding(get: { "Chris" }, set: { _ in }))
}
