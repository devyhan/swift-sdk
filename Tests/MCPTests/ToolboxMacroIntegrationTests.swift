import Foundation
import Testing
import MCP

// Toolbox 매크로가 제거되어 새로운 테스트를 작성합니다.

@Suite("Tool Integration Tests")
struct ToolIntegrationTests {
    @Test("Tools basic usage")
    func testToolsBasicUsage() throws {
        class MathTools {
            @Tool(description: "두 숫자를 더합니다")
            var add: Tool
            
            @Tool(
                description: "두 숫자를 곱합니다", 
                inputSchema: .object([
                    "a": .object(["type": .string("number")]),
                    "b": .object(["type": .string("number")])
                ])
            )
            var multiply: Tool
            
            // 도구 실행 메서드 - 수동으로 구현
            func executeAddition(args: [String: Value]?) throws -> [Tool.Content] {
                guard let args = args,
                      let a = args["a"]?.doubleValue,
                      let b = args["b"]?.doubleValue else {
                    throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
                }
                
                return [.text("결과: \(a + b)")]
            }
            
            func executeMultiplication(args: [String: Value]?) throws -> [Tool.Content] {
                guard let args = args,
                      let a = args["a"]?.doubleValue,
                      let b = args["b"]?.doubleValue else {
                    throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
                }
                
                return [.text("결과: \(a * b)")]
            }
        }
        
        let mathTools = MathTools()
        
        // 도구 검증
        let addTool = mathTools.add
        #expect(addTool.name == "add")
        #expect(addTool.description == "두 숫자를 더합니다")
        #expect(addTool.inputSchema == nil)
        
        let multiplyTool = mathTools.multiply
        #expect(multiplyTool.name == "multiply")
        #expect(multiplyTool.description == "두 숫자를 곱합니다")
        #expect(multiplyTool.inputSchema != nil)
        
        // 도구 실행 검증
        do {
            let addResult = try mathTools.executeAddition(args: ["a": .double(5), "b": .double(3)])
            if case .text(let text) = addResult.first {
                #expect(text == "결과: 8.0")
            } else {
                #expect(Bool(false), "예상된 텍스트 결과가 없습니다")
            }
            
            let multiplyResult = try mathTools.executeMultiplication(args: ["a": .double(5), "b": .double(3)])
            if case .text(let text) = multiplyResult.first {
                #expect(text == "결과: 15.0")
            } else {
                #expect(Bool(false), "예상된 텍스트 결과가 없습니다")
            }
        } catch {
            #expect(Bool(false), "도구 실행 중 오류 발생: \(error)")
        }
    }
    
    @Test("Tools with custom name")
    func testToolsWithCustomName() throws {
        struct CustomNameTools {
            @Tool(name: "customAddition", description: "더하기 연산")
            var add: Tool
            
            @Tool(name: "customSubtraction", description: "빼기 연산")
            var subtract: Tool
        }
        
        let tools = CustomNameTools()
        
        // 도구 검증
        #expect(tools.add.name == "customAddition")
        #expect(tools.add.description == "더하기 연산")
        
        #expect(tools.subtract.name == "customSubtraction")
        #expect(tools.subtract.description == "빼기 연산")
    }
}
