import Foundation
import WS

extension WSID {
    static var demoChat: WSID<DemoChat> { .init() }
}

class DemoChat: ClassicObserver {
    enum Constants {
        static let defaultName = "Anonymous"
    }

    var chatNames = [UUID: String]()

    override func on(open client: AnyClient) {
        let name = client.originalRequest.parameters.get("name") ?? Constants.defaultName
        chatNames[client.id] = name

        client.subscribe(to: "chat", on: eventLoop)

        _ = client.broadcast.channels("chat").send(text: "**\(name)** has joined the chat")
        print("**\(name)** has joined the chat")
    }

    override func on(close client: AnyClient) {
        let name = chatNames[client.id] ?? Constants.defaultName

        _ = client.broadcast.channels("chat").send(text: "**\(name)** has left the chat")
        print("**\(name)** has left the chat")

        client.unsubscribe(from: "chat", on: eventLoop)
        chatNames.removeValue(forKey: client.id)
    }

    override func on(text: String, client: AnyClient) {
        let name = chatNames[client.id] ?? Constants.defaultName
        _ = client.broadcast.channels("chat").send(text: "**\(name)** \(text)")
        print("**\(name)** \(text)")
    }
    /// also you can override: `on(ping:)`, `on(pong:)`, `on(binary:)`, `on(byteBuffer:)`
}
