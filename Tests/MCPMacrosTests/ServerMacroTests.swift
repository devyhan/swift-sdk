#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class ServerMacroTests: MacroBaseTestCase {
    func testServerMacro() {
        assertMacro {
            """
            @main
            @Server(name: "TestServer", version: "1.0.0")
            struct MyServer {
            }
            """
        } expansion: {
            """
            @main
            struct MyServer {
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
                
                private static func setupServer() async throws -> Server {
                    fputs("log: setupServer: creating server instance...\\n", stderr)
                    
                    // 도구 초기화
                    let tools = try await initializeTools()
                    
                    // 서버 생성
                    let server = Server(
                        name: "TestServer",
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
                        guard let tool = tools.first(where: { $0.name == params.name }) else {
                            throw MCPError.methodNotFound("Tool not found: \\(params.name)")
                        }
                        
                        // 도구 이름에 따라 실행 로직 구현
                        throw MCPError.methodNotFound("Tool implementation required: \\(params.name)")
                    }
                }
            }
            """
        }
    }
    
    func testServerMacroWithDefaultValues() {
        assertMacro {
            """
            @main
            @Server
            struct MinimalServer {
            }
            """
        } expansion: {
            """
            @main
            struct MinimalServer {
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
                        guard let tool = tools.first(where: { $0.name == params.name }) else {
                            throw MCPError.methodNotFound("Tool not found: \\(params.name)")
                        }
                        
                        // 도구 이름에 따라 실행 로직 구현
                        throw MCPError.methodNotFound("Tool implementation required: \\(params.name)")
                    }
                }
            }
            """
        }
    }
}
#endif
