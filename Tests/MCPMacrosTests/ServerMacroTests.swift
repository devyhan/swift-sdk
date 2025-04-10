#if canImport(MCPMacros)
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ServerMacroTests: MacroBaseTestCase {
    
    func testServerMacroBasicUsage() {
        assertMacro {
            """
            @Server(name: "TestServer", version: "1.0.0")
            struct MyServer {
                @Tool(name: "echo", description: "Echo tool", inputSchema: .object([
                    "message": .string(description: "Message to echo back")
                ]))
                var echoTool: Tool
                
                func echoToolHandler(arguments: [String: Value]?) async throws -> [Tool.Content] {
                    let message = arguments?["message"]?.stringValue ?? "No message"
                    return [.text("Echo: \\(message)")]
                }
            }
            """
        } expansion: {
            #"""
            struct MyServer {
                var echoTool: Tool {
                    get {
                        let tool = Tool(
                            name: "echo",
                            description: "Echo tool",
                            inputSchema: .object([
                            "message": .string(description: "Message to echo back")
                        ])
                        )
                        return tool
                    }
                }
                
                func echoToolHandler(arguments: [String: Value]?) async throws -> [Tool.Content] {
                    let message = arguments?["message"]?.stringValue ?? "No message"
                    return [.text("Echo: \(message)")]
                }
            }

            /// 서버 인스턴스 생성
            func createServer() -> Server {
                let server = Server(
                    name: "TestServer",
                    version: "1.0.0",
                    capabilities: .default,
                    configuration: .default
                )
                // echo 도구 등록
                server.registerTool(
                    self.echoTool,
                    handler: { [weak self] arguments in
                        guard let self = self else {
                            throw MCPError.internalError("Server was deallocated")
                        }
                        return try await self.echoToolHandler(arguments: arguments)
                    }
                )

                return server
            }

            /// 서버 시작
            /// - Parameter transport: 사용할 트랜스포트
            /// - Returns: 시작된 서버 인스턴스
            func startServer(transport: any Transport) async throws -> Server {
                let server = createServer()
                try await server.start(transport: transport)
                return server
            }

            /// 서버를 생성하고 시작하는 래퍼 메서드
            /// 다른 파일에서 접근할 수 있도록 public으로 선언
            /// - Parameter transport: 사용할 트랜스포트
            /// - Returns: 시작된 서버 인스턴스
            public func createAndStartServer(transport: any Transport) async throws -> Server {
                // 매크로가 생성한 함수 호출
                let server = createServer()
                try await server.start(transport: transport)
                return server
            }
            """#
        }
    }
    
    func testServerMacroWithMultipleTools() {
        assertMacro {
            """
            @Server(name: "MultiToolServer", version: "1.0.0")
            struct MyComplexServer {
                @Tool(name: "echo", description: "Echo tool")
                var echoTool: Tool
                
                @Tool(name: "calculator", description: "Simple calculator")
                var calculatorTool: Tool
                
                func echoToolHandler(arguments: [String: Value]?) async throws -> [Tool.Content] {
                    return [.text("Echo")]
                }
                
                func calculatorToolHandler(arguments: [String: Value]?) async throws -> [Tool.Content] {
                    return [.text("Calculator")]
                }
            }
            """
        } expansion: {
            """
            struct MyComplexServer {
                var echoTool: Tool {
                    get {
                        let tool = Tool(
                            name: "echo",
                            description: "Echo tool",
                            inputSchema: nil
                        )
                        return tool
                    }
                }

                var calculatorTool: Tool {
                    get {
                        let tool = Tool(
                            name: "calculator",
                            description: "Simple calculator",
                            inputSchema: nil
                        )
                        return tool
                    }
                }
                
                func echoToolHandler(arguments: [String: Value]?) async throws -> [Tool.Content] {
                    return [.text("Echo")]
                }
                
                func calculatorToolHandler(arguments: [String: Value]?) async throws -> [Tool.Content] {
                    return [.text("Calculator")]
                }
            }

            /// 서버 인스턴스 생성
            func createServer() -> Server {
                let server = Server(
                    name: "MultiToolServer",
                    version: "1.0.0",
                    capabilities: .default,
                    configuration: .default
                )
                // echo 도구 등록
                server.registerTool(
                    self.echoTool,
                    handler: { [weak self] arguments in
                        guard let self = self else {
                            throw MCPError.internalError("Server was deallocated")
                        }
                        return try await self.echoToolHandler(arguments: arguments)
                    }
                )
                // calculator 도구 등록
                server.registerTool(
                    self.calculatorTool,
                    handler: { [weak self] arguments in
                        guard let self = self else {
                            throw MCPError.internalError("Server was deallocated")
                        }
                        return try await self.calculatorToolHandler(arguments: arguments)
                    }
                )

                return server
            }

            /// 서버 시작
            /// - Parameter transport: 사용할 트랜스포트
            /// - Returns: 시작된 서버 인스턴스
            func startServer(transport: any Transport) async throws -> Server {
                let server = createServer()
                try await server.start(transport: transport)
                return server
            }

            /// 서버를 생성하고 시작하는 래퍼 메서드
            /// 다른 파일에서 접근할 수 있도록 public으로 선언
            /// - Parameter transport: 사용할 트랜스포트
            /// - Returns: 시작된 서버 인스턴스
            public func createAndStartServer(transport: any Transport) async throws -> Server {
                // 매크로가 생성한 함수 호출
                let server = createServer()
                try await server.start(transport: transport)
                return server
            }
            """
        }
    }
    
    func testServerMacroWithCustomCapabilitiesAndConfiguration() {
        assertMacro {
            """
            @Server(
                name: "CustomServer",
                version: "1.0.0",
                capabilities: ServerCapabilities(
                    tools: ServerCapabilities.Tools(listChanged: true)
                ),
                configuration: .strict
            )
            struct CustomServer {
                @Tool(description: "Empty tool")
                var emptyTool: Tool
            }
            """
        } expansion: {
            """
            struct CustomServer {
                var emptyTool: Tool {
                    get {
                        let tool = Tool(
                            name: "emptyTool",
                            description: "Empty tool",
                            inputSchema: nil
                        )
                        return tool
                    }
                }
            }

            /// 서버 인스턴스 생성
            func createServer() -> Server {
                let server = Server(
                    name: "CustomServer",
                    version: "1.0.0",
                    capabilities: ServerCapabilities(
                    tools: ServerCapabilities.Tools(listChanged: true)
                ),
                    configuration: .strict
                )
                // emptyTool 도구 등록 (핸들러 없음)
                server.registerTool(self.emptyTool)

                return server
            }

            /// 서버 시작
            /// - Parameter transport: 사용할 트랜스포트
            /// - Returns: 시작된 서버 인스턴스
            func startServer(transport: any Transport) async throws -> Server {
                let server = createServer()
                try await server.start(transport: transport)
                return server
            }

            /// 서버를 생성하고 시작하는 래퍼 메서드
            /// 다른 파일에서 접근할 수 있도록 public으로 선언
            /// - Parameter transport: 사용할 트랜스포트
            /// - Returns: 시작된 서버 인스턴스
            public func createAndStartServer(transport: any Transport) async throws -> Server {
                // 매크로가 생성한 함수 호출
                let server = createServer()
                try await server.start(transport: transport)
                return server
            }
            """
        }
    }
}
#endif
