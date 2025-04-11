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

### Important Notes for Server Implementation

1. **Do not use the `@main` attribute** with the `@Server` macro
2. **Do not name your file `main.swift`** - use a different name like `server.swift`
3. **Use a unique struct name** to avoid naming conflicts

## More Information

For more details, see the [official MCP documentation][mcp].

## License

This project is licensed under the MIT License.

[mcp]: https://modelcontextprotocol.io
