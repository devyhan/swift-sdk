import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

// SwiftDiagnostics에서 필요한 타입들을 더 쉽게 사용하기 위한 타입 참조
fileprivate typealias Diagnostic = SwiftDiagnostics.Diagnostic
fileprivate typealias DiagnosticMessage = SwiftDiagnostics.DiagnosticMessage
fileprivate typealias DiagnosticSeverity = SwiftDiagnostics.DiagnosticSeverity
fileprivate typealias MessageID = SwiftDiagnostics.MessageID

/// MCP 서버 매크로 구현
// 매크로 확장을 위한 인터페이스
public protocol DiagnosticEmitter {}

/// MCP 서버 매크로 구현
public struct ServerMacro: MemberMacro, DiagnosticEmitter {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclSyntaxProtocol,
        conformingTo protocols: [TypeSyntax] = [],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 속성 목록에서 @main 속성을 찾습니다
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            // @main 속성을 업그레이드된 방식으로 확인
            let hasMainAttribute = structDecl.attributes.contains { attr in
                // 속성이 AttributeSyntax 타입인지 확인
                guard let attributeSyntax = attr.as(AttributeSyntax.self) else { return false }
                
                // 속성 이름이 IdentifierTypeSyntax (기본 식별자 속성)인지 확인
                if let identifierType = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self) {
                    // 정확히 "main" 텍스트인지 확인
                    let isMainAttribute = identifierType.name.text == "main"
                    
                    // 추가 검증: 속성이 다른 인자나 사용자 정의 값을 가지지 않는지 확인
                    let hasNoArguments = attributeSyntax.arguments == nil
                    
                    return isMainAttribute && hasNoArguments
                }
                
                return false
            }
            
            // @main 속성이 발견되면 경고를 출력합니다
            if hasMainAttribute {
                // 진단 메시지 구성
                struct MainDiagnosticMessage: DiagnosticMessage {
                    let message: String
                    let diagnosticID: MessageID
                    let severity: DiagnosticSeverity
                    
                    var id: MessageID { diagnosticID }
                }
                
                let diagnosticMessage = MainDiagnosticMessage(
                    message: "@Server 매크로와 @main 속성은 함께 사용할 수 없습니다. @Server 매크로는 자체적으로 static func main() 메서드를 생성하여 프로그램의 진입점을 제공합니다. 해결 방법: 1) @main 속성을 제거하고 2) 파일명을 'main.swift'가 아닌 다른 이름으로 변경하세요.",
                    diagnosticID: MessageID(domain: "MCP.Server", id: "duplicate.main"),
                    severity: .warning
                )
                
                let diagnostic = Diagnostic(node: node, message: diagnosticMessage)
                context.diagnose(diagnostic)
            }
        }
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
        
        // 구조체 내부의 @Tool 매크로가 적용된 변수들을 찾습니다
        let toolVariables = findToolVariables(in: structDecl)
        
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
        
        // initializeTools 메서드 - @Tool 변수를 자동으로 추가
        if !existingMethods.contains("initializeTools") {
            // 구조체 내부에 @Tool 매크로가 있는 경우
            if !toolVariables.isEmpty {
                let toolsInitCode = toolVariables.map { "\($0)" }.joined(separator: ", ")
                declarations.append(DeclSyntax(stringLiteral: """
                private static func initializeTools() async throws -> [Tool] {
                    // 구조체에서 정의된 @Tool 변수들을 자동으로 추가
                    return [\(toolsInitCode)]
                }
                """))
            } else {
                // 구조체 내부에 @Tool 매크로가 없는 경우 기본 동작
                declarations.append(DeclSyntax(stringLiteral: """
                private static func initializeTools() async throws -> [Tool] {
                    // 이 메서드를 오버라이드하여 도구 초기화 로직 구현
                    return []
                }
                """))
            }
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
    
    // 구조체 내부의 @Tool 매크로가 적용된 변수들을 찾는 메서드
    private static func findToolVariables(in structDecl: StructDeclSyntax) -> [String] {
        var toolVariables: [String] = []
        
        for member in structDecl.memberBlock.members {
            // 변수 선언인지 확인
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
            
            // 변수에 @Tool 매크로가 적용되었는지 확인
            let hasToolMacro = varDecl.attributes.contains { attr in
                if let attr = attr.as(AttributeSyntax.self),
                   let attrName = attr.attributeName.as(IdentifierTypeSyntax.self) {
                    return attrName.name.text == "Tool"
                }
                return false
            }
            
            if hasToolMacro {
                // 변수 이름 가져오기
                for binding in varDecl.bindings {
                    if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                        toolVariables.append("self.\(pattern.identifier.text)")
                    }
                }
            }
        }
        
        return toolVariables
    }
}
