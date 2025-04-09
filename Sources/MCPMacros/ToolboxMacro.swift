import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// 클래스나 구조체에 도구 모음 기능을 추가하는 매크로
public struct ToolboxMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        <#code#>
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 매개변수 추출
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let nameArg = args.first(where: { $0.label?.text == "name" })?.expression,
              let descArg = args.first(where: { $0.label?.text == "description" })?.expression else {
            throw MacroError("@Toolbox 매크로에는 name과 description 매개변수가 필요합니다")
        }
        
        // 도구 모음 정보 메서드 생성
        let infoMethod = """
        func getToolboxInfo() -> (name: String, description: String) {
            return (\(nameArg.description), \(descArg.description))
        }
        """
        
        // 도구 목록 메서드 생성
        let toolsMethod = """
        func getTools() -> [Tool] {
            var tools: [Tool] = []
            for method in _getToolDefinitionMethods() {
                if let tool = self.perform(method)?.takeRetainedValue() as? Tool {
                    tools.append(tool)
                }
            }
            return tools
        }
        
        private func _getToolDefinitionMethods() -> [Selector] {
            var methods: [Selector] = []
            let mirror = Mirror(reflecting: self)
            for child in mirror.children {
                if let methodName = child.label, methodName.hasPrefix("_toolDefinition_") {
                    if let selector = NSSelectorFromString(methodName) {
                        methods.append(selector)
                    }
                }
            }
            return methods
        }
        """
        
        // 도구 호출 핸들러 생성
        var cases: [String] = []
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
        
        return [
            DeclSyntax(stringLiteral: infoMethod),
            DeclSyntax(stringLiteral: toolsMethod),
            DeclSyntax(stringLiteral: handlerMethod)
        ]
    }
}

/// MCP 도구 모음을 나타내는 프로토콜
public protocol MCPToolbox {
    /// 도구 모음에 대한 정보 반환
    func getToolboxInfo() -> (name: String, description: String)
    
    /// 도구 모음에 포함된 모든 도구 반환
    func getTools() -> [Tool]
    
    /// 도구 호출 처리
    func handleToolCall(name: String, arguments: [String: Value]?) throws -> [Tool.Content]
}
