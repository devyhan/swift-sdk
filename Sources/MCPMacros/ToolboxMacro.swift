import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Toolbox 매크로 구현
public struct ToolboxMacro: MemberMacro, ConformanceMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 매개변수 추출
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let nameExpr = arguments.first(where: { $0.label?.text == "name" })?.expression.as(StringLiteralExprSyntax.self),
              let descExpr = arguments.first(where: { $0.label?.text == "description" })?.expression.as(StringLiteralExprSyntax.self) else {
            throw MacroError("Toolbox macro requires name and description parameters")
        }
        
        let name = nameExpr.segments.description
        let description = descExpr.segments.description
        
        // 도구 모음 메타데이터 메서드
        let metadataMethod = """
        public func getToolboxMetadata() -> (name: String, description: String) {
            return (\(name), \(description))
        }
        """
        
        // getMCPTools 메서드 - 비어있는 기본 구현
        let toolsMethod = """
        public func getMCPTools() -> [Tool] {
            var tools: [Tool] = []
            // @Tool 매크로가 적용된 메서드들이 여기에 도구를 등록할 것입니다
            return tools
        }
        """
        
        return [
            DeclSyntax(stringLiteral: metadataMethod),
            DeclSyntax(stringLiteral: toolsMethod)
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [(TypeSyntax("MCPToolbox"), nil)]
    }
}
