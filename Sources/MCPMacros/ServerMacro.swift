import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// MCP 서버 매크로 구현
public struct ServerMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclSyntaxProtocol,
        conformingTo protocols: [TypeSyntax] = [],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError("@Server는 구조체에만 적용할 수 있습니다")
        }
        
        // 매크로 인자 파싱
        let args = node.arguments?.as(LabeledExprListSyntax.self)
        let nameArg = args?.first(where: { $0.label?.text == "name" })?.expression
        let versionArg = args?.first(where: { $0.label?.text == "version" })?.expression
        let capabilitiesArg = args?.first(where: { $0.label?.text == "capabilities" })?.expression
        
        let serverName = nameArg?.description ?? "\"MCPServer\""
        let serverVersion = versionArg?.description ?? "\"1.0.0\""
        let serverCapabilities = capabilitiesArg?.description ?? ".init()"
        
        // 기존 구현을 확인하여 중복 생성을 피합니다
        let existingMethods = structDecl.memberBlock.members.compactMap { member -> String? in
            guard let methodDecl = member.decl.as(FunctionDeclSyntax.self) else { return nil }
            return methodDecl.name.text
        }
        
        var declarations: [DeclSyntax] = []
        
        // main 메서드
        if !existingMethods.contains("main") {
            declarations.append(DeclSyntax(stringLiteral: """
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
            """))
        }
        
        // setupServer 메서드
        if !existingMethods.contains("setupServer") {
            declarations.append(DeclSyntax(stringLiteral: """
            private static func setupServer() async throws -> Server {
                fputs("log: setupServer: creating server instance...\\n", stderr)
                
                // 도구 초기화
                let tools = try await initializeTools()
                
                // 서버 생성
                let server = Server(
                    name: \(serverName),
                    version: \(serverVersion),
                    capabilities: \(serverCapabilities)
                )
                
                // 핸들러 등록
                try await registerHandlers(server: server, tools: tools)
                
                // 서버 시작
                let transport = StdioTransport()
                try await server.start(transport: transport)
                
                return server
            }
            """))
        }
        
        // initializeTools 메서드
        if !existingMethods.contains("initializeTools") {
            declarations.append(DeclSyntax(stringLiteral: """
            private static func initializeTools() async throws -> [Tool] {
                // 이 메서드를 오버라이드하여 도구 초기화 로직 구현
                return []
            }
            """))
        }
        
        // registerHandlers 메서드
        if !existingMethods.contains("registerHandlers") {
            declarations.append(DeclSyntax(stringLiteral: """
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
            """))
        }
        
        return declarations
    }
}
