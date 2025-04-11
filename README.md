# MCP Swift SDK

Swift implementation of the [Model Context Protocol][mcp] (MCP).

## 최근 업데이트 내용

### 2023-04-11: 서버 매크로 개선
- `@Server` 매크로가 `@main` 속성과 충돌하는 문제 수정
- 더 정확한 진단 메시지 제공
- 사용자 가이드 업데이트

## Requirements

- Swift 6.0+ / Xcode 16+
- macOS 13.0+
- iOS / Mac Catalyst 16.0+
- watchOS 9.0+
- tvOS 16.0+
- visionOS 1.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.7.1")
]
```

## Usage

### Basic Client Setup

```swift
import MCP

// Initialize the client
let client = Client(name: "MyApp", version: "1.0.0")

// Create a transport and connect
let transport = StdioTransport()
try await client.connect(transport: transport)

// Initialize the connection
let result = try await client.initialize()
```

### MCP Server Implementation

#### Standalone Server (with automatic `main()` method)

```swift
// server.swift (Not main.swift!)
import MCP
import Foundation

@Server(
    name: "MyServer", 
    version: "1.0.0",
    capabilities: .init(
        tools: .init(listChanged: true)
    )
    // generateMain: true (Default)
)
struct MCPServerImpl {
    // Define tools using @Tool macro
    @Tool(
        name: "echo",
        description: "Echoes back the input text",
        inputSchema: .object([
            "message": .object([
                "type": .string("string"),
                "description": .string("The text to echo back")
            ])
        ])
    )
    static var echoTool: Tool
    
    // Optional: Override registerHandlers to customize handler registration
    private static func registerHandlers(server: Server, tools: [Tool]) async throws {
        await server.withMethodHandler(CallTool.self) { params in
            if params.name == "echo",
               let args = params.arguments,
               let message = args["message"]?.stringValue {
                return .init(content: [.text(message)])
            }
            throw MCPError.methodNotFound("Tool not found: \(params.name)")
        }
    }
}
```

#### Using with Custom Entry Point (@main)

For custom entry points, set `generateMain: false` to avoid conflicts:

```swift
// server.swift
import MCP

@Server(
    name: "MyServer", 
    version: "1.0.0",
    generateMain: false  // Important: Don't generate main method
)
struct ServerImpl {
    // Server implementation
}

// main.swift
import Foundation
import MCP

@main
struct App {
    static func main() {
        Task {
            do {
                let server = try await ServerImpl.setupServer()
                await server.waitUntilCompleted()
            } catch {
                print("Error: \(error)")
                exit(1)
            }
        }
        RunLoop.main.run()
    }
}
```

### Important Notes for Server Implementation

1. When using standalone mode:
   - **Do not use the `@main` attribute** with the `@Server` macro
   - **Do not name your file `main.swift`** - use a different name like `server.swift`

2. When integrating with custom entry point:
   - Set `generateMain: false` in the `@Server` macro
   - Call `setupServer()` from your main function

3. **Use a unique struct name** to avoid naming conflicts

## More Information

For more details, see the [official MCP documentation][mcp].

## License

This project is licensed under the MIT License.

[mcp]: https://modelcontextprotocol.io
