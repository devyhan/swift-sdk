import Foundation
import MCP

// 예제: 에코 서버 구현
class EchoServer: @unchecked Sendable {
    // 기본 초기화 구문 추가
    init() {}
    // 도구 정의: @Tool 매크로 사용
    @Tool(
        name: "swift_echo",
        description: "A simple tool that echoes back its input arguments.",
        inputSchema: .object([
            "message": .string("The text to echo back")
        ])
    )
    var echoTool: Tool
    
    // 도구 핸들러: echoToolHandler 이름 형식으로 자동 매핑됨
    func echoToolHandler(arguments: [String: Value]?) async throws -> [Tool.Content] {
        let message = arguments?["message"]?.stringValue ?? "No message provided"
        return [.text("Echo: \(message)")]
    }
    
    // 서버 초기화 이벤트 핸들러
    func onInitialize(clientInfo: Client.Info, capabilities: Client.Capabilities) {
        print("Client connected: \(clientInfo.name)")
    }
}

// 서버 클래스 확장 추가 (ServerMacro가 자동으로 생성할 코드)
extension EchoServer {
    /// 서버 인스턴스 생성
    func createServer() async -> Server {
        let server = Server(
            name: "SwiftEchoServer", 
            version: "1.0.0"
        )
        
        // echoTool 도구 등록
        await server.registerTool(
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
    func startServer(transport: any Transport) async throws -> Server {
        let server = await createServer()
        try await server.start(transport: transport, initializeHook: { [weak self] clientInfo, capabilities in
            self?.onInitialize(clientInfo: clientInfo, capabilities: capabilities)
        })
        return server
    }
}

// 실행 예제
@main
struct ServerApp {
    static func main() async throws {
        // 서버 인스턴스 생성 및 시작
        let echoServer = EchoServer()
        
        print("Starting EchoServer...")
        
        // ServerMacro가 생성한 createServer와 startServer 메서드 사용
        let server = try await echoServer.startServer(transport: StdioTransport())
        
        // 서버가 종료될 때까지 대기
        await server.waitUntilCompleted()
    }
}
