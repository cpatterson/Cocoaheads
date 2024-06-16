import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: LocalizedStringKey
    let isLocal: Bool

    init(text: String, isLocal: Bool) {
        self.text = LocalizedStringKey(text)
        self.isLocal = isLocal
    }
}

struct ChatView: View {
    @Binding var name: String?
    @State var newMessage = ""
    @State var messages: [ChatMessage] = []
    @State var connection: WebSocketConnection?
    @FocusState var isFocused: Bool

    var chatURL: URL? {
        guard let name else { return nil }
        return URL(string: "ws://vision.local:8080/chat/\(name)")!
    }

    var body: some View {
        NavigationView {
            VStack {
                Divider()
                ScrollView {
                    ForEach($messages) { message in
                        MessageView(message: message)
                    }
                }
                TextField(text: $newMessage, prompt: Text("Type a message...")) {
                    Text("Chat")
                }
                .onSubmit {
                    sendMessage(newMessage)
                }
                .focused($isFocused)
                .padding(.horizontal, 25)
                .padding(.vertical)
                .background {
                    Color.mint.opacity(0.1)
                    Capsule()
                        .fill(.white)
                        .clipShape(.capsule)
                        .padding(8)
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: { 
                            disconnect()
                            name = nil
                        },
                        label: {
                            Text("Sign Out")
                        }
                    )
                }
            }
            .onAppear {
                isFocused = true
                connect()
            }
            .onDisappear {
                disconnect()
            }
            .onChange(of: name) {
                connect()
            }
        }
    }

    func connect() {
        guard let name, let chatURL else { return }
        connection = WebSocketConnection.connect(url: chatURL, stringReceived: { message in
            messages.append(ChatMessage(text: message, isLocal: message.hasPrefix("**\(name)**")))
        })
    }

    func disconnect() {
        connection?.close()
        connection = nil
    }

    func sendMessage(_ text: String) {
        connection?.send(text: text) { error in
            guard let error else { return }
            messages.append(ChatMessage(text: "_Error sending: \(error.localizedDescription)_", isLocal: false))
        }
        newMessage = ""
        isFocused = true
    }
}

struct MessageView: View {
    @Binding var message: ChatMessage

    var body: some View {
        Text(message.text)
            .multilineTextAlignment(message.isLocal ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: message.isLocal ? .trailing : .leading)
            .padding()
    }
}

#Preview {
    ChatView(name: Binding(get: { "Chris" }, set: { _ in }))
}
