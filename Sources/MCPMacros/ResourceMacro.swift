import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// 속성을 MCP 리소스로 만들어주는 매크로
public struct ResourceMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw MacroError("@Resource는 변수에만 적용할 수 있습니다")
        }
        
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let uriArg = args.first(where: { $0.label?.text == "uri" })?.expression else {
            throw MacroError("@Resource에는 uri 매개변수가 필요합니다")
        }
        
        // name 매개변수 추출 (없으면 변수 이름 사용)
        let nameArg = args.first(where: { $0.label?.text == "name" })?.expression
        let resourceName = nameArg != nil ? nameArg!.description : "\"\(identifier)\""
        
        // description 매개변수 추출 (선택적)
        let descArg = args.first(where: { $0.label?.text == "description" })?.expression
        let descValue = descArg?.description ?? "nil"
        
        // mimeType 매개변수 추출 (선택적)
        let mimeTypeArg = args.first(where: { $0.label?.text == "mimeType" })?.expression
        let mimeTypeValue = mimeTypeArg?.description ?? "nil"
        
        // metadata 매개변수 추출 (선택적)
        let metadataArg = args.first(where: { $0.label?.text == "metadata" })?.expression
        let metadataValue = metadataArg?.description ?? "nil"
        
        // getter 생성
        let getterString = """
        get {
            let resource = Resource(
                name: \(resourceName),
                uri: \(uriArg.description),
                description: \(descValue),
                mimeType: \(mimeTypeValue),
                metadata: \(metadataValue)
            )
            return resource
        }
        """
        
        return [AccessorDeclSyntax(stringLiteral: getterString)]
    }
}
