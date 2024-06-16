import SwiftUI

struct ContentView: View {
    @State var name: String?
    @State var isPresenting = false

    func updateState() {
        isPresenting = (name == nil)
    }

    var body: some View {
        TabView {
            ChatView(name: $name)
                .tabItem {
                    TabLabel(imageName: "text.bubble", label: "Chat")
                }

            GameView(name: $name)
                .tabItem {
                    TabLabel(imageName: "grid", label: "Play")
                }

            PaintView(name: $name)
                .tabItem {
                    TabLabel(imageName: "paintpalette", label: "Paint")
                }
        }
        .onAppear {
            updateState()
        }
        .onChange(of: name) {
            updateState()
        }
        .sheet(isPresented: $isPresenting) {
            SignInSheet(name: $name)
        }
    }
}

struct TabLabel: View {
    let imageName: String
    let label: String

    var body: some View {
        HStack {
            Image(systemName: imageName)
            Text(label)
        }
    }
}

#Preview {
    ContentView()
}
