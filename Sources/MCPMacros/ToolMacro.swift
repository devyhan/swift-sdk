import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// 속성을 MCP 도구로 만들어주는 매크로
public struct ToolMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw MacroError("@Tool은 변수에만 적용할 수 있습니다")
        }
        
        // 설명 추출
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let descArg = args.first(where: { $0.label?.text == "description" })?.expression else {
            throw MacroError("@Tool에는 description 매개변수가 필요합니다")
        }
        
        // 스키마 추출 (있는 경우)
        let schemaArg = args.first(where: { $0.label?.text == "schema" })?.expression
        let schemaValue = schemaArg?.description ?? """
        .object([
            "type": .string("object"),
            "properties": .object([
                "message": .object([
                    "type": .string("string"),
                    "description": .string("Input parameter")
                ])
            ]),
            "required": .array([.string("message")])
        ])
        """
        
        // getter 생성
        let getterString = """
        get {
            let tool = Tool(
                name: "\(identifier)",
                description: \(descArg.description),
                inputSchema: \(schemaValue)
            )
            // 도구 모음에 도구 등록
            if let toolbox = self as? (any MCPToolbox) {
                if let mutableToolbox = toolbox as? (AnyObject) {
                    let selector = Selector(("_registerTool:"))
                    _ = mutableToolbox.perform(selector, with: tool)
                }
            }
            return tool
        }
        """
        
        return [AccessorDeclSyntax(stringLiteral: getterString)]
    }
}
