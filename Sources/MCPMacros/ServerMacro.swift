import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Server 매크로는 구조체나 클래스를 MCP 서버로 확장합니다.
/// 이 매크로는 서버 인스턴스를 생성하고, 도구와 핸들러를 자동으로 연결하는 기능을 제공합니다.
/// 또한 래퍼 메서드를 자동으로 추가하여 다른 파일에서도 서버 기능에 접근할 수 있게 합니다.
public struct ServerMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 구조체나 클래스만 처리
        let typeName: String
        let memberBlock: MemberBlockSyntax
        
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            typeName = structDecl.name.text
            memberBlock = structDecl.memberBlock
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            typeName = classDecl.name.text
            memberBlock = classDecl.memberBlock
        } else {
            throw MacroError("@Server는 구조체나 클래스에만 적용할 수 있습니다")
        }
        
        // 매크로 인자 추출
        guard let args = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw MacroError("@Server 매크로에 필요한 인자가 없습니다")
        }
        
        // name과 version 인자는 필수
        guard let nameArg = args.first(where: { $0.label?.text == "name" })?.expression,
              let versionArg = args.first(where: { $0.label?.text == "version" })?.expression else {
            throw MacroError("@Server 매크로에는 name과 version 인자가 필요합니다")
        }
        
        // 선택적 인자 추출
        let capabilitiesArg = args.first(where: { $0.label?.text == "capabilities" })?.expression ?? ExprSyntax(stringLiteral: ".default")
        let configurationArg = args.first(where: { $0.label?.text == "configuration" })?.expression ?? ExprSyntax(stringLiteral: ".default")
        
        // 도구 속성 찾기
        let toolProperties = findToolProperties(in: memberBlock)
        
        // 핸들러 메서드 찾기
        let handlerMethods = findHandlerMethods(in: memberBlock)
        
        // 도구와 핸들러 매핑
        let toolHandlerMappings = mapToolsToHandlers(tools: toolProperties, handlers: handlerMethods)
        
        // 서버 생성 메서드
        let createServerMethod = createServerMethodString(
            structName: typeName,
            serverName: nameArg.description,
            serverVersion: versionArg.description,
            capabilities: capabilitiesArg.description,
            configuration: configurationArg.description,
            toolHandlerMappings: toolHandlerMappings
        )
        
        // 서버 시작 메서드
        let startServerMethod = createStartServerMethodString(structName: typeName)
        
        // 래퍼 메서드 - 타입 내부에 생성
        let wrapperMethod = createWrapperMethodString()
        
        // 각 디클레이션을 분리해서 생성
        let createServerDecl = DeclSyntax(stringLiteral: createServerMethod)
        let startServerDecl = DeclSyntax(stringLiteral: startServerMethod)
        let wrapperMethodDecl = DeclSyntax(stringLiteral: wrapperMethod)
        
        return [createServerDecl, startServerDecl, wrapperMethodDecl]
    }
    
    // MARK: - Helper Methods
    
    /// 구조체나 클래스에서 @Tool 속성 찾기
    private static func findToolProperties(in memberBlock: MemberBlockSyntax) -> [(name: String, property: String)] {
        var tools: [(name: String, property: String)] = []
        
        for member in memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }
            
            // @Tool 매크로가 적용되었는지 확인
            let hasToolMacro = varDecl.attributes.contains { attribute in
                guard let attribute = attribute.as(AttributeSyntax.self) else { return false }
                return attribute.attributeName.description.contains("Tool")
            }
            
            if hasToolMacro, let binding = varDecl.bindings.first,
               let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                let propertyName = pattern.identifier.text
                
                // 도구 이름 추출 (name 인자가 있으면 사용, 없으면 속성 이름 사용)
                var toolName = propertyName
                if let attributes = varDecl.attributes.first(where: {
                    $0.as(AttributeSyntax.self)?.attributeName.description.contains("Tool") ?? false
                }),
                   let args = attributes.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self),
                   let nameArg = args.first(where: { $0.label?.text == "name" }) {
                    // 문자열 리터럴에서 따옴표와 이스케이프 문자 제거
                    var extractedName = nameArg.expression.description
                    extractedName = extractedName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if extractedName.hasPrefix("\"") && extractedName.hasSuffix("\"") {
                        extractedName = String(extractedName.dropFirst().dropLast())
                    }
                    toolName = extractedName
                }
                
                tools.append((name: toolName, property: propertyName))
            }
        }
        
        return tools
    }
    
    /// 핸들러 메서드 찾기 (toolNameHandler 형식)
    private static func findHandlerMethods(in memberBlock: MemberBlockSyntax) -> [String] {
        var handlers: [String] = []
        
        for member in memberBlock.members {
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else { continue }
            
            let methodName = funcDecl.name.text
            if methodName.hasSuffix("Handler") {
                handlers.append(methodName)
            }
        }
        
        return handlers
    }
    
    /// 도구와 핸들러 매핑
    private static func mapToolsToHandlers(
        tools: [(name: String, property: String)],
        handlers: [String]
    ) -> [(tool: String, property: String, handler: String?)] {
        tools.map { tool in
            // 도구 이름에 해당하는 핸들러 찾기 (toolNameHandler 형식)
            let expectedHandler = "\(tool.property)Handler"
            let handler = handlers.first { $0 == expectedHandler }
            
            return (tool: tool.name, property: tool.property, handler: handler)
        }
    }
    
    /// 서버 생성 메서드 문자열 생성
    private static func createServerMethodString(
        structName: String,
        serverName: String,
        serverVersion: String,
        capabilities: String,
        configuration: String,
        toolHandlerMappings: [(tool: String, property: String, handler: String?)]
    ) -> String {
        var registrations = ""
        
        for mapping in toolHandlerMappings {
            if let handler = mapping.handler {
                registrations += """
                
                    // \(mapping.tool) 도구 등록
                    server.registerTool(
                        self.\(mapping.property),
                        handler: { [weak self] arguments in
                            guard let self = self else {
                                throw MCPError.internalError("Server was deallocated")
                            }
                            return try await self.\(handler)(arguments: arguments)
                        }
                    )
                """
            } else {
                registrations += """
                
                    // \(mapping.tool) 도구 등록 (핸들러 없음)
                    server.registerTool(self.\(mapping.property))
                """
            }
        }
        
        return """
/// 서버 인스턴스 생성
func createServer() -> Server {
    let server = Server(
        name: \(serverName),
        version: \(serverVersion),
        capabilities: \(capabilities),
        configuration: \(configuration)
    )\(registrations)
    
    return server
}
"""
    }
    
    /// 서버 시작 메서드 문자열 생성
    private static func createStartServerMethodString(structName: String) -> String {
        return """
/// 서버 시작
/// - Parameter transport: 사용할 트랜스포트
/// - Returns: 시작된 서버 인스턴스
func startServer(transport: any Transport) async throws -> Server {
    let server = createServer()
    try await server.start(transport: transport)
    return server
}
"""
    }
    
    /// 래퍼 메서드 문자열 생성 - 타입 내부에 추가되는 메서드
    private static func createWrapperMethodString() -> String {
        return """
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
