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
        
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let descArg = args.first(where: { $0.label?.text == "description" })?.expression else {
            throw MacroError("@Tool에는 description 매개변수가 필요합니다")
        }
        
        // name 매개변수 추출 (없으면 변수 이름 사용)
        let nameArg = args.first(where: { $0.label?.text == "name" })?.expression
        let toolName = nameArg != nil ? nameArg!.description : "\"\(identifier)\""
        
        // inputSchema 매개변수 추출 (있는 경우)
        let schemaArg = args.first(where: { $0.label?.text == "inputSchema" })?.expression
        let schemaValue = schemaArg?.description ?? "nil"
        
        // getter 생성
        let getterString = """
        get {
            let tool = Tool(
                name: \(toolName),
                description: \(descArg.description),
                inputSchema: \(schemaValue)
            )
            return tool
        }
        """
        
        return [AccessorDeclSyntax(stringLiteral: getterString)]
    }
}
