# README

This repo contains the demo projects and Keynote presentation for my Indy Cocoaheads talk, presented June 18, 2024.

## Let's Get Real(time) with WebSockets

Usually, iOS apps use standard HTTP(S) protocols to communicate with remote servers and/or other users of the system. 
However, that's often not a great solution, especially for realtime communications, as is needed for things like live chat, group messaging, collaboration tools and gaming.

In my talk, I demonstrate real-time communications for your app using WebSockets, a streaming data protocol with support built-in to `URLSession` as of iOS 13. 

We'll go over:
- Creating a websocket connection
- sending and receiving simple text messages
- sending and receiving `Codable` data structures
- setting up a simple websocket server using [Vapor](https://vapor.codes/)
- macOS websocket dev tools: [Proxyman](https://proxyman.io/), [Cleora](https://cleora.app/), [wscat](https://github.com/websockets/wscat)
- link to a [curated list](https://github.com/facundofarias/awesome-websockets) of websocket tools for any language

## Projecs in this Repo
1. WebSocketDemoServer - A simple Vapor app that uses AwesomeWS library to provide 2 websocket services: a chat app and a tic-tac-toe game.
2. WebSocketDemoApp - A simplle SwiftUI iOS app that connects to the above server and provides a simple chat interface and tic-tac-toe game.
