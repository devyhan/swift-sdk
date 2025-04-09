//import Foundation
//import Testing
//import MCP
//
//@Suite("Toolbox Integration Tests")
//struct ToolboxIntegrationTests {
//    @Test("Toolbox with tools")
//    func testToolboxWithTools() throws {
//        @Toolbox(name: "수학 도구 모음", description: "수학 관련 도구를 제공합니다")
//        class MathTools {
//            @Tool(description: "두 숫자를 더합니다")
//            var add: Tool
//            
//            @Tool(description: "두 숫자를 곱합니다", 
//                  schema: .object([
//                    "a": .object(["type": .string("number")]),
//                    "b": .object(["type": .string("number")])
//                  ]))
//            var multiply: Tool
//            
//            // 이 메서드는 매크로에 의해 생성된 _executeAdd 메서드를 재정의합니다
//            private func _executeAdd(arguments: [String: Value]?) throws -> [Tool.Content] {
//                guard let args = arguments,
//                      let a = args["a"]?.doubleValue,
//                      let b = args["b"]?.doubleValue else {
//                    throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
//                }
//                
//                return [.text("결과: \(a + b)")]
//            }
//            
//            // 이 메서드는 매크로에 의해 생성된 _executeMultiply 메서드를 재정의합니다
//            private func _executeMultiply(arguments: [String: Value]?) throws -> [Tool.Content] {
//                guard let args = arguments,
//                      let a = args["a"]?.doubleValue,
//                      let b = args["b"]?.doubleValue else {
//                    throw MCPError.invalidParams("숫자 a와 b가 필요합니다")
//                }
//                
//                return [.text("결과: \(a * b)")]
//            }
//        }
//        
//        let tools = MathTools()
//        
//        // 도구 모음 정보 검증
//        let info = tools.getToolboxInfo()
//        #expect(info.name == "수학 도구 모음")
//        #expect(info.description == "수학 관련 도구를 제공합니다")
//        
//        // 도구 목록 검증
//        let toolsList = tools.getTools()
//        #expect(toolsList.count == 2)
//        #expect(toolsList.contains { $0.name == "add" })
//        #expect(toolsList.contains { $0.name == "multiply" })
//        
//        // 도구 실행 검증
//        do {
//            let addResult = try tools.handleToolCall(name: "add", arguments: ["a": 5, "b": 3])
//            if case .text(let text) = addResult.first {
//                #expect(text == "결과: 8.0")
//            } else {
//                #expect(Bool(false), "예상된 텍스트 결과가 없습니다")
//            }
//            
//            let multiplyResult = try tools.handleToolCall(name: "multiply", arguments: ["a": 5, "b": 3])
//            if case .text(let text) = multiplyResult.first {
//                #expect(text == "결과: 15.0")
//            } else {
//                #expect(Bool(false), "예상된 텍스트 결과가 없습니다")
//            }
//        } catch {
//            #expect(Bool(false), "도구 실행 중 오류 발생: \(error)")
//        }
//    }
//}
