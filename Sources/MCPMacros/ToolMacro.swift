import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// 속성을 MCP 도구로 만들어주는 매크로
public struct ToolMacro: AccessorMacro, MemberMacro {
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
            return Tool(
                name: "\(identifier)",
                description: \(descArg.description),
                inputSchema: \(schemaValue)
            )
        }
        """
        
        return [AccessorDeclSyntax(stringLiteral: getterString)]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var members: [DeclSyntax] = []
        
        // 도구 속성 찾기
        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               let binding = varDecl.bindings.first,
               let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
               varDecl.attributes.contains(where: {
                   $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Tool"
               }) {
                
                // 도구 정의 메서드 생성
                let definitionMethod = """
                @objc func _toolDefinition_\(identifier)() -> Any {
                    return self.\(identifier)
                }
                """
                members.append(DeclSyntax(stringLiteral: definitionMethod))
                
                // 도구 실행 메서드 생성
                let executeMethod = """
                func _execute\(identifier.capitalized)(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 '\(identifier)' 실행됨 (인자: \\(arguments?.description ?? "없음"))")]
                }
                """
                members.append(DeclSyntax(stringLiteral: executeMethod))
            }
        }
        
        return members
    }
}
