import MCP

@Toolbox(name: "계산 도구", description: "다양한 계산 기능을 제공합니다")
struct CalculatorTools {  // MCPToolbox 프로토콜 구현 추가
    @Tool(description: "두 숫자의 합을 계산합니다")
    var add: Tool
    
    func _executeAdd(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let args = arguments,
              let a = args["a"]?.doubleValue,
              let b = args["b"]?.doubleValue else {
            throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
        }
        
        return [.text("결과: \(a + b)")]
    }
}
