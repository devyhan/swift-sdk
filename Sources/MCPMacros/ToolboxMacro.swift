import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ToolboxMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 매개변수 추출
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let nameArg = args.first(where: { $0.label?.text == "name" })?.expression,
              let descArg = args.first(where: { $0.label?.text == "description" })?.expression else {
            throw MacroError("Missing required parameters")
        }
        
        // 메타데이터 메서드 생성
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
        
        return [DeclSyntax(stringLiteral: infoMethod), DeclSyntax(stringLiteral: toolsMethod)]
    }
    
    // 여기서 제네릭 파라미터 T를 사용하여, 프로토콜이 요구하는 "some TypeSyntax" 요구사항을 충족합니다.
    public static func expansion<T: TypeSyntaxProtocol>(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo type: T,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // type을 문자열로 변환한 후 좌우 공백 제거하여 비교
        let typeName = "\(type)".trimmingCharacters(in: .whitespacesAndNewlines)
        if typeName == "MCPToolbox" {
            return try expansion(of: node, providingMembersOf: declaration, in: context)
        }
        return []
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [(TypeSyntax("MCPToolbox"), nil)]
    }
}
