import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// 클래스나 구조체에 도구 모음 기능을 추가하는 매크로
public struct ToolboxMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // MCPToolbox 프로토콜을 구현하는 extension 생성
        let extensionDecl = try ExtensionDeclSyntax("extension \(type): MCPToolbox {}")
        return [extensionDecl]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 매개변수 추출
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let nameArg = args.first(where: { $0.label?.text == "name" })?.expression,
              let descArg = args.first(where: { $0.label?.text == "description" })?.expression else {
            throw MacroError("@Toolbox 매크로에는 name과 description 매개변수가 필요합니다")
        }
        
        // 도구 저장 배열 추가
        let toolsProperty = """
        private var _tools: [Tool] = []
        """
        
        // 도구 모음 정보 메서드 생성
        let infoMethod = """
        func getToolboxInfo() -> (name: String, description: String) {
            return (\(nameArg.description), \(descArg.description))
        }
        """
        
        // 도구 목록 메서드 생성 (리플렉션 대신 내부 배열 사용)
        let toolsMethod = """
        func getTools() -> [Tool] {
            return _tools
        }
        
        fileprivate mutating func _registerTool(_ tool: Tool) {
            // 이미 등록된 동일한 이름의 도구가 있으면 중복 등록 방지
            if !_tools.contains(where: { $0.name == tool.name }) {
                _tools.append(tool)
            }
        }
        """
        
        // 도구 호출 핸들러 생성
        var cases: [String] = []
        var executeMethods: [String] = []
        
        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               let binding = varDecl.bindings.first,
               let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
               varDecl.attributes.contains(where: {
                   $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Tool"
               }) {
                let toolCase = """
                case "\(identifier)":
                    return try _execute\(identifier.capitalized)(arguments: arguments)
                """
                cases.append(toolCase)
                
                // 도구 실행 메서드 생성 - private 접근 제어자 추가
                let executeMethod = """
                private func _execute\(identifier.capitalized)(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 '\(identifier)' 실행됨 (인자: \\(arguments?.description ?? "없음"))")]
                }
                """
                executeMethods.append(executeMethod)
            }
        }
        
        let handlerMethod = """
        func handleToolCall(name: String, arguments: [String: Value]?) throws -> [Tool.Content] {
            switch name {
            \(cases.joined(separator: "\n"))
            default:
                throw MCPError.methodNotFound("Tool not found: \\(name)")
            }
        }
        """
        
        var result: [DeclSyntax] = [
            DeclSyntax(stringLiteral: toolsProperty),
            DeclSyntax(stringLiteral: infoMethod),
            DeclSyntax(stringLiteral: toolsMethod),
            DeclSyntax(stringLiteral: handlerMethod)
        ]
        
        // 실행 메서드 추가
        for method in executeMethods {
            result.append(DeclSyntax(stringLiteral: method))
        }
        
        return result
    }
}
