import MCP
import Foundation

@Toolbox(name: "계산 도구", description: "다양한 계산 기능을 제공합니다")
struct CalculatorTools {  // MCPToolbox 프로토콜 구현 추가
    @Tool(description: "두 숫자의 합을 계산합니다")
    var add: Tool
    
    @Tool(description: "두 숫자의 차이를 계산합니다")
    var subtract: Tool
    
    @Tool(description: "두 숫자의 곱을 계산합니다")
    var multiply: Tool
    
    // 이제 실행 메서드는 Toolbox 매크로에 의해 자동 생성되므로 아래 메서드들을 제거합니다
    // 주석으로 남겨두어 참고할 수 있게 합니다
    /*
    private func _executeAdd(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let args = arguments,
              let a = args["a"]?.doubleValue,
              let b = args["b"]?.doubleValue else {
            throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
        }
        
        return [.text("결과: \(a + b)")]
    }
    
    private func _executeSubtract(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let args = arguments,
              let a = args["a"]?.doubleValue,
              let b = args["b"]?.doubleValue else {
            throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
        }
        
        return [.text("결과: \(a - b)")]
    }
    
    private func _executeMultiply(arguments: [String: Value]?) throws -> [Tool.Content] {
        guard let args = arguments,
              let a = args["a"]?.doubleValue,
              let b = args["b"]?.doubleValue else {
            throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
        }
        
        return [.text("결과: \(a * b)")]
    }
    */
}
