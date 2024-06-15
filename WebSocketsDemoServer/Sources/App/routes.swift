import Vapor
import WS

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        return "Hello, world!"
    }

    app.get("hello", ":name") { req async -> String in
        guard let name = req.parameters.get("name") else {
            return "Hello, world!"
        }
        return "Hello, \(name)!"
    }

    app.ws.build(.demoChat).at("chat", ":name").serve()
}
