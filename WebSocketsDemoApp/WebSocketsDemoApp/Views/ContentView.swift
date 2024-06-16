import SwiftUI

struct ContentView: View {
    @State var name: String

    var body: some View {
        TabView {
            ChatView(name: name)
                .tabItem {
                    TabLabel(imageName: "text.bubble", label: "Chat")
                }

            GameView()
                .tabItem {
                    TabLabel(imageName: "grid", label: "Play")
                }

            PaintView()
                .tabItem {
                    TabLabel(imageName: "paintpalette", label: "Paint")
                }
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
    ContentView(name: "Chris")
}
