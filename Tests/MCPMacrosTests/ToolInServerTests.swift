#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class ToolInServerTests: MacroBaseTestCase {
    func testServerWithToolVariables() {
        assertMacro {
            """
            @main
            @Server(name: "ToolServer", version: "1.0.0")
            struct MCPServer {
                @Tool(
                    name: "echo",
                    description: "Echoes back text"
                )
                static var echoTool: Tool
                
                @Tool(
                    name: "reverse",
                    description: "Reverses text"
                )
                static var reverseTool: Tool
                
                private static func registerHandlers(server: Server, tools: [Tool]) async throws {
                    // 핸들러 구현
                }
            }
            """
        } expansion: {
            """
            @main
            struct MCPServer {
                @Tool(
                    name: "echo",
                    description: "Echoes back text"
                )
                static var echoTool: Tool
                
                @Tool(
                    name: "reverse",
                    description: "Reverses text"
                )
                static var reverseTool: Tool
                
                private static func registerHandlers(server: Server, tools: [Tool]) async throws {
                    // 핸들러 구현
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
                
                private static func setupServer() async throws -> Server {
                    fputs("log: setupServer: creating server instance...\\n", stderr)
                    
                    // 도구 초기화
                    let tools = try await initializeTools()
                    
                    // 서버 생성
                    let server = Server(
                        name: "ToolServer",
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
                    return [self.echoTool, self.reverseTool]
                }
            }
            """
        }
    }
}
#endif
