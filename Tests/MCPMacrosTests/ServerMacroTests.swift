#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class ServerMacroTests: MacroBaseTestCase {
    func testServerWithDefaults() {
        assertMacro {
            """
            @Server
            struct MCPServerImpl {
            }
            """
        } expansion: {
            """
            struct MCPServerImpl {
                private static func setupServer() async throws -> Server {
                    fputs("log: setupServer: creating server instance...\\n", stderr)
                    
                    // 도구 초기화
                    let tools = try await initializeTools()
                    
                    // 서버 생성
                    let server = Server(
                        name: "MCPServer",
                        version: "1.0.0",
                        capabilities: .init()
                    )
                    
                    // 핸들러 등록
                    try await registerHandlers(server: server, tools: tools)
                    
                    // 서버 시작
                    let transport = StdioTransport()
                    try await server.start(transport: transport)
                    
                    return server
                }
                
                private static func initializeTools() async throws -> [Tool] {
                    // 이 메서드를 오버라이드하여 도구 초기화 로직 구현
                    return []
                }
                
                private static func registerHandlers(server: Server, tools: [Tool]) async throws {
                    // 이 메서드를 오버라이드하여 핸들러 등록 로직 구현
                    await server.withMethodHandler(ListTools.self) { _ in
                        return ListTools.Result(tools: tools)
                    }
                    
                    await server.withMethodHandler(CallTool.self) { params in
                        // 이 메서드를 오버라이드하여 실제 도구 실행 로직 구현
                        throw MCPError.methodNotFound("Tool implementation required: \\(params.name)")
                    }
                }
                
                static func main() async {
                    fputs("log: main: starting (async).\\n", stderr)
                    
                    let server: Server
                    do {
                        server = try await setupServer()
                        fputs("log: main: server started successfully, waiting for completion...\\n", stderr)
                        await server.waitUntilCompleted()
                        fputs("log: main: server has stopped.\\n", stderr)
                    } catch {
                        fputs("error: main: server setup/run failed: \\(error)\\n", stderr)
                        exit(1)
                    }
                    
                    fputs("log: main: Server processing finished. Exiting.\\n", stderr)
                }
            }
            """
        }
    }
    
    func testServerWithCustomParameters() {
        assertMacro {
            """
            @Server(name: "CustomServer", version: "2.0.0", generateMain: false)
            struct CustomServer {
            }
            """
        } expansion: {
            """
            struct CustomServer {
                private static func setupServer() async throws -> Server {
                    fputs("log: setupServer: creating server instance...\\n", stderr)
                    
                    // 도구 초기화
                    let tools = try await initializeTools()
                    
                    // 서버 생성
                    let server = Server(
                        name: "CustomServer",
                        version: "2.0.0",
                        capabilities: .init()
                    )
                    
                    // 핸들러 등록
                    try await registerHandlers(server: server, tools: tools)
                    
                    // 서버 시작
                    let transport = StdioTransport()
                    try await server.start(transport: transport)
                    
                    return server
                }
                
                private static func initializeTools() async throws -> [Tool] {
                    // 이 메서드를 오버라이드하여 도구 초기화 로직 구현
                    return []
                }
                
                private static func registerHandlers(server: Server, tools: [Tool]) async throws {
                    // 이 메서드를 오버라이드하여 핸들러 등록 로직 구현
                    await server.withMethodHandler(ListTools.self) { _ in
                        return ListTools.Result(tools: tools)
                    }
                    
                    await server.withMethodHandler(CallTool.self) { params in
                        // 이 메서드를 오버라이드하여 실제 도구 실행 로직 구현
                        throw MCPError.methodNotFound("Tool implementation required: \\(params.name)")
                    }
                }
            }
            """
        }
    }
    
    func testServerWithAtMainConflict() {
        assertMacro {
            """
            @main
            @Server
            struct ConflictingServer {
            }
            """
        } diagnostics: {
            """
            @main
            @Server
            ┬─────
            ╰─ 🛑 @Server cannot be used with @main. The @Server macro generates its own 'static func main()'. Solutions: 1) Remove @main or 2) Use a separate file for main entry point.
            struct ConflictingServer {
            }
            """
        } expansion: {
            """
            @main
            struct ConflictingServer {
                private static func setupServer() async throws -> Server {
                    fputs("log: setupServer: creating server instance...\\n", stderr)
                    
                    // 도구 초기화
                    let tools = try await initializeTools()
                    
                    // 서버 생성
                    let server = Server(
                        name: "MCPServer",
                        version: "1.0.0",
                        capabilities: .init()
                    )
                    
                    // 핸들러 등록
                    try await registerHandlers(server: server, tools: tools)
                    
                    // 서버 시작
                    let transport = StdioTransport()
                    try await server.start(transport: transport)
                    
                    return server
                }
                
                private static func initializeTools() async throws -> [Tool] {
                    // 이 메서드를 오버라이드하여 도구 초기화 로직 구현
                    return []
                }
                
                private static func registerHandlers(server: Server, tools: [Tool]) async throws {
                    // 이 메서드를 오버라이드하여 핸들러 등록 로직 구현
                    await server.withMethodHandler(ListTools.self) { _ in
                        return ListTools.Result(tools: tools)
                    }
                    
                    await server.withMethodHandler(CallTool.self) { params in
                        // 이 메서드를 오버라이드하여 실제 도구 실행 로직 구현
                        throw MCPError.methodNotFound("Tool implementation required: \\(params.name)")
                    }
                }
            }
            """
        }
    }
    
    func testServerWithGenerateMainFalse() {
        assertMacro {
            """
            @main
            @Server(generateMain: false)
            struct CompatibleServer {
            }
            """
        } expansion: {
            """
            @main
            struct CompatibleServer {
                private static func setupServer() async throws -> Server {
                    fputs("log: setupServer: creating server instance...\\n", stderr)
                    
                    // 도구 초기화
                    let tools = try await initializeTools()
                    
                    // 서버 생성
                    let server = Server(
                        name: "MCPServer",
                        version: "1.0.0",
                        capabilities: .init()
                    )
                    
                    // 핸들러 등록
                    try await registerHandlers(server: server, tools: tools)
                    
                    // 서버 시작
                    let transport = StdioTransport()
                    try await server.start(transport: transport)
                    
                    return server
                }
                
                private static func initializeTools() async throws -> [Tool] {
                    // 이 메서드를 오버라이드하여 도구 초기화 로직 구현
                    return []
                }
                
                private static func registerHandlers(server: Server, tools: [Tool]) async throws {
                    // 이 메서드를 오버라이드하여 핸들러 등록 로직 구현
                    await server.withMethodHandler(ListTools.self) { _ in
                        return ListTools.Result(tools: tools)
                    }
                    
                    await server.withMethodHandler(CallTool.self) { params in
                        // 이 메서드를 오버라이드하여 실제 도구 실행 로직 구현
                        throw MCPError.methodNotFound("Tool implementation required: \\(params.name)")
                    }
                }
            }
            """
        }
    }
    
    func testServerWithTools() {
        assertMacro {
            """
            @Server
            struct ServerWithTools {
                @Tool(description: "Echo tool")
                var echo: Tool
                
                @Tool(description: "Calculator tool")
                var calculator: Tool
            }
            """
        } expansion: {
            """
            struct ServerWithTools {
                @Tool(description: "Echo tool")
                var echo: Tool
                
                @Tool(description: "Calculator tool")
                var calculator: Tool
                
                private static func setupServer() async throws -> Server {
                    fputs("log: setupServer: creating server instance...\\n", stderr)
                    
                    // 도구 초기화
                    let tools = try await initializeTools()
                    
                    // 서버 생성
                    let server = Server(
                        name: "MCPServer",
                        version: "1.0.0",
                        capabilities: .init()
                    )
                    
                    // 핸들러 등록
                    try await registerHandlers(server: server, tools: tools)
                    
                    // 서버 시작
                    let transport = StdioTransport()
                    try await server.start(transport: transport)
                    
                    return server
                }
                
                private static func initializeTools() async throws -> [Tool] {
                    // 구조체에서 정의된 @Tool 변수들을 자동으로 추가
                    return [self.echo, self.calculator]
                }
                
                private static func registerHandlers(server: Server, tools: [Tool]) async throws {
                    // 이 메서드를 오버라이드하여 핸들러 등록 로직 구현
                    await server.withMethodHandler(ListTools.self) { _ in
                        return ListTools.Result(tools: tools)
                    }
                    
                    await server.withMethodHandler(CallTool.self) { params in
                        // 이 메서드를 오버라이드하여 실제 도구 실행 로직 구현
                        throw MCPError.methodNotFound("Tool implementation required: \\(params.name)")
                    }
                }
                
                static func main() async {
                    fputs("log: main: starting (async).\\n", stderr)
                    
                    let server: Server
                    do {
                        server = try await setupServer()
                        fputs("log: main: server started successfully, waiting for completion...\\n", stderr)
                        await server.waitUntilCompleted()
                        fputs("log: main: server has stopped.\\n", stderr)
                    } catch {
                        fputs("error: main: server setup/run failed: \\(error)\\n", stderr)
                        exit(1)
                    }
                    
                    fputs("log: main: Server processing finished. Exiting.\\n", stderr)
                }
            }
            """
        }
    }
}
#endif
