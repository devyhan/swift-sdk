import MCP
import Foundation

// @Toolbox 매크로가 제거되어 다음과 같이 변경되었습니다
struct CalculatorTools {
    @Tool(description: "두 숫자의 합을 계산합니다")
    var add: Tool
    
    @Tool(description: "두 숫자의 차이를 계산합니다")
    var subtract: Tool
    
    @Tool(description: "두 숫자의 곱을 계산합니다")
    var multiply: Tool
    
    // 각 도구에 대한 실행 메서드를 직접 구현해야 합니다
    func executeAdd(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let args = arguments,
              let a = args["a"]?.doubleValue,
              let b = args["b"]?.doubleValue else {
            throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
        }
        
        return [.text("결과: \(a + b)")]
    }
    
    func executeSubtract(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let args = arguments,
              let a = args["a"]?.doubleValue,
              let b = args["b"]?.doubleValue else {
            throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
        }
        
        return [.text("결과: \(a - b)")]
    }
    
    func executeMultiply(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let args = arguments,
              let a = args["a"]?.doubleValue,
              let b = args["b"]?.doubleValue else {
            throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
        }
        
        return [.text("결과: \(a * b)")]
    }
}
