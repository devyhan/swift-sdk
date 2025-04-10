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

                /// 서버 인스턴스
                fileprivate(set) public var server: Server = Server(
                    name: "TestServer",
                    version: "1.0.0",
                    capabilities: .default,
                    configuration: .default
                )

                /// 서버 초기화 및 도구 등록
                /// - Parameter additionalSetup: 추가 설정을 위한 선택적 클로저
                /// - Returns: 초기화된 서버 인스턴스
                public func initializeServer(additionalSetup: ((Server) async throws -> Void)? = nil) async throws -> Server {
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

                    // 추가 설정 수행
                    if let setup = additionalSetup {
                        try await setup(server)
                    }

                    return server
                }

                /// 서버 시작 (초기화 포함)
                /// - Parameters:
                ///   - transport: 사용할 트랜스포트
                ///   - setup: 추가 설정을 위한 선택적 클로저
                /// - Returns: 시작된 서버 인스턴스
                public func startServer(
                    transport: any Transport,
                    setup: ((Server) async throws -> Void)? = nil
                ) async throws -> Server {
                    let initializedServer = try await initializeServer(additionalSetup: setup)
                    try await initializedServer.start(transport: transport)
                    return initializedServer
                }
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

                /// 서버 인스턴스
                fileprivate(set) public var server: Server = Server(
                    name: "MultiToolServer",
                    version: "1.0.0",
                    capabilities: .default,
                    configuration: .default
                )

                /// 서버 초기화 및 도구 등록
                /// - Parameter additionalSetup: 추가 설정을 위한 선택적 클로저
                /// - Returns: 초기화된 서버 인스턴스
                public func initializeServer(additionalSetup: ((Server) async throws -> Void)? = nil) async throws -> Server {
                    // echo 도구 등록
                server.registerTool(
                    self.echoTool,
                    handler: { [weak self] arguments in
                        guard let self = self else {
                            throw MCPError.internalError("Server was deallocated")
                        }
                        return try await self.echoToolHandler(arguments: arguments)
                    }
                    )// calculator 도구 등록
                    server.registerTool(
                        self.calculatorTool,
                        handler: { [weak self] arguments in
                            guard let self = self else {
                                throw MCPError.internalError("Server was deallocated")
                            }
                            return try await self.calculatorToolHandler(arguments: arguments)
                        }
                    )

                    // 추가 설정 수행
                    if let setup = additionalSetup {
                        try await setup(server)
                    }

                    return server
                }

                /// 서버 시작 (초기화 포함)
                /// - Parameters:
                ///   - transport: 사용할 트랜스포트
                ///   - setup: 추가 설정을 위한 선택적 클로저
                /// - Returns: 시작된 서버 인스턴스
                public func startServer(
                    transport: any Transport,
                    setup: ((Server) async throws -> Void)? = nil
                ) async throws -> Server {
                    let initializedServer = try await initializeServer(additionalSetup: setup)
                    try await initializedServer.start(transport: transport)
                    return initializedServer
                }
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

                /// 서버 인스턴스
                fileprivate(set) public var server: Server = Server(
                    name: "CustomServer",
                    version: "1.0.0",
                    capabilities: ServerCapabilities(
                        tools: ServerCapabilities.Tools(listChanged: true)
                    ),
                    configuration: .strict
                )

                /// 서버 초기화 및 도구 등록
                /// - Parameter additionalSetup: 추가 설정을 위한 선택적 클로저
                /// - Returns: 초기화된 서버 인스턴스
                public func initializeServer(additionalSetup: ((Server) async throws -> Void)? = nil) async throws -> Server {
                    // emptyTool 도구 등록 (핸들러 없음)
                server.registerTool(self.emptyTool)

                    // 추가 설정 수행
                    if let setup = additionalSetup {
                        try await setup(server)
                    }

                    return server
                }

                /// 서버 시작 (초기화 포함)
                /// - Parameters:
                ///   - transport: 사용할 트랜스포트
                ///   - setup: 추가 설정을 위한 선택적 클로저
                /// - Returns: 시작된 서버 인스턴스
                public func startServer(
                    transport: any Transport,
                    setup: ((Server) async throws -> Void)? = nil
                ) async throws -> Server {
                    let initializedServer = try await initializeServer(additionalSetup: setup)
                    try await initializedServer.start(transport: transport)
                    return initializedServer
                }
            }
            """
        }
    }
}
#endif
