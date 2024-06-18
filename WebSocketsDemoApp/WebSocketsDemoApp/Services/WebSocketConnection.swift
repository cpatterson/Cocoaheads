import Foundation

extension Swift.Error {
    var isRequestTimeoutError: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == -1001
    }
}
class WebSocketConnection: NSObject {
    typealias StringReceiveHandler = (String) -> Void
    typealias DecodableReceiveHandler<Object: Decodable> = (Object) -> Void
    typealias MessageReceiveHandler = (URLSessionWebSocketTask.Message) -> Void
    typealias SendHandler = (Swift.Error?) -> Void

    public enum Error: Swift.Error {
        case connectionClosed
    }

    public static func connect(
        url: URL,
        stringReceived: StringReceiveHandler? = nil
    ) -> WebSocketConnection {
        WebSocketConnection(url: url) { message in
            switch message {
            case let .string(string):
                stringReceived?(string)
            case let .data(data):
                if let string = String(data: data, encoding: .utf8) {
                    stringReceived?(string)
                } else {
                    debugPrint("WebSocketConnection: decoding data as UTF-8 string failed: \(data)")
                }
            @unknown default:
                debugPrint("WebSocketConnection: unexpected message received: \(message)")
            }
        }
    }

    public static func connect<Object>(
        url: URL,
        objectReceived: DecodableReceiveHandler<Object>? = nil
    ) -> WebSocketConnection {
        WebSocketConnection(url: url) { message in
            switch message {
            case let .string(string):
                if let data = string.data(using: .utf8) {
                    dataReceived(data, handler: objectReceived)
                } else {
                    debugPrint("WebSocketConnection: encoding string as UTF-8 data failed: \(string)")
                }
            case let .data(data):
                dataReceived(data, handler: objectReceived)
            @unknown default:
                debugPrint("WebSocketConnection: unexpected message received: \(message)")
            }
        }
    }

    private let webSocketTask: URLSessionWebSocketTask
    private let messageReceived: MessageReceiveHandler

    public let url: URL
    public var isClosed: Bool { webSocketTask.closeCode != .invalid }

    // Public Foundation objects that can be swapped out as needed,
    // - with mocks for unit testing
    // - to provide custom behaviors
    public static var encoder = JSONEncoder()
    public static var decoder = JSONDecoder()
    public static var mainQueue = DispatchQueue.main
    public static var backgroundQueue = DispatchQueue.global(qos: .background)

    private init(url: URL, messageReceived: @escaping MessageReceiveHandler) {
        self.url = url
        self.webSocketTask = URLSession.shared.webSocketTask(with: url)
        self.messageReceived = messageReceived

        super.init()

        receiveNextMessage()
        webSocketTask.resume()
    }

    private func receiveNextMessage() {
        WebSocketConnection.backgroundQueue.schedule { [weak self] in
            guard let self, !isClosed else { return }
            webSocketTask.receive { [weak self] result in
                guard let self, !isClosed else { return }
                switch result {
                case let .success(message):
                    WebSocketConnection.mainQueue.schedule { [weak self] in
                        self?.messageReceived(message)
                    }
                case let .failure(error):
                    debugPrint("WebSocketConnection: error receiving message: \(error.localizedDescription)")
                    if error.isRequestTimeoutError, !isClosed {
                        webSocketTask.cancel(with: .abnormalClosure, reason: error.localizedDescription.data(using: .utf8))
                        messageReceived(.string("*Error: \(error.localizedDescription)*"))
                        return
                    }
                }

                // Recursively call this method again if we haven't been cancelled
                // Wait a half-second to avoid a really hard loop
                let delay = WebSocketConnection.backgroundQueue.now.advanced(by: .milliseconds(500))
                WebSocketConnection.backgroundQueue.schedule(after: delay) { [weak self] in
                    guard let self, !isClosed else { return }
                    receiveNextMessage()
                }
            }
        }
    }

    public func close() {
        if isClosed { return }
        webSocketTask.cancel(with: .normalClosure, reason: "Client closed connection".data(using: .utf8))
    }

    public func send(text: String, completion: SendHandler? = nil) {
        if isClosed {
            completion?(Error.connectionClosed)
            return
        }
        WebSocketConnection.backgroundQueue.schedule { [weak self] in
            self?.webSocketTask.send(.string(text)) { error in
                WebSocketConnection.mainQueue.schedule {
                    completion?(error)
                }
            }
        }
    }

    public func send(object: Codable, completion: SendHandler? = nil) {
        if isClosed {
            completion?(Error.connectionClosed)
            return
        }
        WebSocketConnection.backgroundQueue.schedule { [weak self] in
            guard let self else { return }
            do {
                let data = try WebSocketConnection.encoder.encode(object)
                webSocketTask.send(.data(data)) { error in
                    WebSocketConnection.mainQueue.schedule {
                        completion?(error)
                    }
                }
            } catch {
                WebSocketConnection.mainQueue.schedule {
                    completion?(error)
                }
            }
        }
    }

    private static func dataReceived<Object>(_ data: Data, handler: DecodableReceiveHandler<Object>?) {
        do {
            let object = try WebSocketConnection.decoder.decode(Object.self, from: data)
            handler?(object)
        } catch {
            debugPrint(
                """
                WebSocketConnection: error decoding object of type \(Object.self): \(error.localizedDescription)
                \(String(data: data, encoding: .utf8) ?? "(nil UTF-8 string value)")
                """
            )
        }
    }
}
