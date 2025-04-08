import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Tool 매크로 구현
public struct ToolMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroError("@Tool can only be applied to functions")
        }
        
        // 도구 설명 추출
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let descExpr = arguments.first(where: { $0.label?.text == "description" })?.expression.as(StringLiteralExprSyntax.self) else {
            throw MacroError("Tool macro requires a description parameter")
        }
        
        let description = descExpr.segments.description
        let toolName = funcDecl.name.text
        
        // 매개변수 정보 추출
        let parameters = extractParametersInfo(from: funcDecl, in: context)
        
        // 입력 스키마 코드 생성
        let schemaCode = generateInputSchemaCode(parameters: parameters)
        
        // 도구 등록 도우미 메서드
        let toolRegistrationMethod = """
        // \(toolName) 도구를 등록하기 위한 도우미 메서드
        private func register_\(toolName)_tool() -> Tool {
            return Tool(
                name: "\(toolName)",
                description: \(description),
                inputSchema: \(schemaCode)
            )
        }
        """
        
        // 도구 호출 핸들러 메서드
        let toolHandlerMethod = """
        // \(toolName) 도구를 처리하기 위한 핸들러
        func handle_\(toolName)_call(arguments: [String: Value]?) throws -> [Tool.Content] {
            \(generateParameterExtractionCode(parameters: parameters))
            
            let result = \(toolName)(\(generateArgumentsCode(parameters: parameters)))
            return [ToolUtils.valueToContent(result)]
        }
        """
        
        // getMCPTools 확장 메서드
        let toolsExtensionMethod = """
        // getMCPTools 확장 - \(toolName) 도구를 등록합니다
        extension \(funcDecl.parent!.as(DeclGroupSyntax.self)!.name!.text) {
            func get\(toolName.capitalized)Tool() -> Tool {
                return register_\(toolName)_tool()
            }
        }
        """
        
        return [
            DeclSyntax(stringLiteral: toolRegistrationMethod),
            DeclSyntax(stringLiteral: toolHandlerMethod),
            DeclSyntax(stringLiteral: toolsExtensionMethod)
        ]
    }
    
    // 매개변수 정보 추출 헬퍼 함수
    private static func extractParametersInfo(
        from function: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) -> [(name: String, type: String, description: String)] {
        var result: [(name: String, type: String, description: String)] = []
        
        if let paramList = function.signature.parameterClause.parameters {
            for param in paramList {
                let paramName = param.firstName?.text ?? param.secondName?.text ?? ""
                let paramType = param.type.description
                
                // @Param 매크로에서 설명 추출 (간단한 구현)
                var description = "Parameter \(paramName)"
                
                // 실제 구현에서는 속성 확인과 설명 추출이 필요합니다
                // ...
                
                result.append((name: paramName, type: paramType, description: description))
            }
        }
        
        return result
    }
    
    // JSON 스키마 코드 생성
    private static func generateInputSchemaCode(parameters: [(name: String, type: String, description: String)]) -> String {
        if parameters.isEmpty {
            return "nil"
        }
        
        var propertyLines = parameters.map { param -> String in
            let typeValue: String
            
            // Swift 타입을 JSON 스키마 타입으로 변환
            switch param.type.trimmingCharacters(in: .whitespacesAndNewlines) {
            case "Int", "Int32", "Int64", "UInt", "UInt32", "UInt64":
                typeValue = ".string(\"integer\")"
            case "Float", "Double", "CGFloat":
                typeValue = ".string(\"number\")"
            case "Bool":
                typeValue = ".string(\"boolean\")"
            default:
                typeValue = ".string(\"string\")"
            }
            
            return """
                "\(param.name)": .object([
                    "type": \(typeValue),
                    "description": .string("\(param.description)")
                ])
            """
        }
        
        let propertiesString = propertyLines.joined(separator: ",\n            ")
        let requiredParams = parameters.filter { !$0.type.contains("?") }.map { $0.name }
        let requiredString = requiredParams.map { ".string(\"\($0)\")" }.joined(separator: ", ")
        
        return """
        .object([
            "type": .string("object"),
            "properties": .object([
                \(propertiesString)
            ]),
            "required": .array([\(requiredString)])
        ])
        """
    }
    
    // 매개변수 추출 코드 생성
    private static func generateParameterExtractionCode(parameters: [(name: String, type: String, description: String)]) -> String {
        if parameters.isEmpty {
            return "// 매개변수 없음"
        }
        
        return parameters.map { param -> String in
            let valueExtraction: String
            
            // Swift 타입별 Value 추출 코드 생성
            switch param.type.trimmingCharacters(in: .whitespacesAndNewlines) {
            case "Int", "Int32", "Int64":
                valueExtraction = "arguments?[\"\(param.name)\"]?.intValue ?? 0"
            case "Float", "Double", "CGFloat":
                valueExtraction = "arguments?[\"\(param.name)\"]?.doubleValue ?? 0.0"
            case "Bool":
                valueExtraction = "arguments?[\"\(param.name)\"]?.boolValue ?? false"
            default:
                valueExtraction = "arguments?[\"\(param.name)\"]?.stringValue ?? \"\""
            }
            
            return "let \(param.name) = \(valueExtraction)"
        }.joined(separator: "\n        ")
    }
    
    // 함수 호출 인자 코드 생성
    private static func generateArgumentsCode(parameters: [(name: String, type: String, description: String)]) -> String {
        return parameters.map { $0.name }.joined(separator: ", ")
    }
}
