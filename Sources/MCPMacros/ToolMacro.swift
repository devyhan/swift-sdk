import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ToolMacro: AccessorMacro, MemberMacro {
    // AccessorMacro 구현
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
            throw MacroError("@Tool must be applied to a variable")
        }
        
        // 도구 설명 추출
        guard let args = node.arguments?.as(LabeledExprListSyntax.self),
              let descArg = args.first(where: { $0.label?.text == "description" })?.expression else {
            throw MacroError("@Tool requires a description parameter")
        }
        
        // 접근자 생성 - 도구 정의를 반환하는 계산 속성
        let getterString = """
        get {
            let schema: Value = .object([
                "type": .string("object"),
                "properties": .object([
                    "message": .object([
                        "type": .string("string"),
                        "description": .string("Input parameter")
                    ])
                ]),
                "required": .array([.string("message")])
            ])
            
            return Tool(
                name: "\(identifier)",
                description: \(descArg.description),
                inputSchema: schema
            )
        }
        """
        
        return [AccessorDeclSyntax(stringLiteral: getterString)]
    }
    
    // MemberMacro: 기존 멤버들을 제공하는 구현
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // struct, class, enum 등으로 캐스팅하여 타입 이름 추출
        let typeName: String
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            typeName = structDecl.identifier.text
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            typeName = classDecl.identifier.text
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            typeName = enumDecl.identifier.text
        } else {
            typeName = "UnknownType"
        }
        
        var toolDefinitionMethods: [String] = []
        
        // 선언된 멤버들 중 @Tool 속성이 적용된 변수에 대해 정의 메서드 생성
        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               let binding = varDecl.bindings.first,
               let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
               varDecl.attributes.contains(where: {
                   $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Tool"
               }) {
                
                let methodName = "_toolDefinition_\(identifier)"
                let method = """
                @objc func \(methodName)() -> Any {
                    return self.\(identifier)
                }
                """
                toolDefinitionMethods.append(method)
            }
        }
        
        // 도구 호출 처리 메서드 생성
        let handleToolCallMethod = """
        func handleToolCall(name: String, arguments: [String: Value]?) throws -> [Tool.Content] {
            switch name {
            // (개별 도구들에 대한 케이스 추가는 실제 구현 시 필요)
            default:
                throw NSError(domain: "MCPToolbox", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tool not found: \\(name)"])
            }
        }
        """
        
        return toolDefinitionMethods.map { DeclSyntax(stringLiteral: $0) } + [DeclSyntax(stringLiteral: handleToolCallMethod)]
    }
    
    // MemberMacro: 프로토콜이 요구하는 conformingTo 메서드 구현
    // 'conformingTo' 파라미터의 타입을 'TypeSyntax'로 선언 (some 제거)
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo type: TypeSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // type을 문자열로 변환 후 좌우 공백 제거하여 비교
        let typeName = "\(type)".trimmingCharacters(in: .whitespacesAndNewlines)
        // 필요에 따라 특정 타입에 대해 분기할 수 있으나, 여기서는 무조건 멤버 확장을 반환함.
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
}
