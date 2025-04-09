#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class IntegrationTests: MacroBaseTestCase {
    func testCalculatorToolboxIntegration() {
        assertMacro {
            """
            @Toolbox(name: "고급 계산기", description: "수학 계산 기능을 제공합니다")
            class AdvancedCalculator {
                @Tool(description: "두 숫자의 거듭제곱을 계산합니다")
                var power: Tool
                
                @Tool(description: "숫자의 제곱근을 계산합니다")
                var sqrt: Tool
                
                private func _executePower(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let base = args["base"]?.doubleValue,
                          let exponent = args["exponent"]?.doubleValue else {
                        throw MCPError.invalidParams("base와 exponent 매개변수가 필요합니다")
                    }
                    
                    let result = pow(base, exponent)
                    return [.text("결과: \\(result)")]
                }
                
                private func _executeSqrt(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let value = args["value"]?.doubleValue else {
                        throw MCPError.invalidParams("value 매개변수가 필요합니다")
                    }
                    
                    if value < 0 {
                        throw MCPError.invalidParams("음수의 제곱근은 계산할 수 없습니다")
                    }
                    
                    let result = sqrt(value)
                    return [.text("결과: \\(result)")]
                }
            }
            """
        } expansion: {
            #"""
            class AdvancedCalculator {
                var power: Tool {
                    get {
                        let tool = Tool(
                            name: "power",
                            description: "두 숫자의 거듭제곱을 계산합니다",
                            inputSchema: .object([
                        "type": .string("object"),
                        "properties": .object([
                            "message": .object([
                                "type": .string("string"),
                                "description": .string("Input parameter")
                            ])
                        ]),
                        "required": .array([.string("message")])
                                ])
                        )
                        // 도구 모음에 도구 등록
                        if let toolbox = self as? (any MCPToolbox) {
                            if let mutableToolbox = toolbox as? (AnyObject) {
                                let selector = Selector(("_registerTool:"))
                                _ = mutableToolbox.perform(selector, with: tool)
                            }
                        }
                        return tool
                    }
                }

                var sqrt: Tool {
                    get {
                        let tool = Tool(
                            name: "sqrt",
                            description: "숫자의 제곱근을 계산합니다",
                            inputSchema: .object([
                        "type": .string("object"),
                        "properties": .object([
                            "message": .object([
                                "type": .string("string"),
                                "description": .string("Input parameter")
                            ])
                        ]),
                        "required": .array([.string("message")])
                                ])
                        )
                        // 도구 모음에 도구 등록
                        if let toolbox = self as? (any MCPToolbox) {
                            if let mutableToolbox = toolbox as? (AnyObject) {
                                let selector = Selector(("_registerTool:"))
                                _ = mutableToolbox.perform(selector, with: tool)
                            }
                        }
                        return tool
                    }
                }
                
                private func _executePower(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let base = args["base"]?.doubleValue,
                          let exponent = args["exponent"]?.doubleValue else {
                        throw MCPError.invalidParams("base와 exponent 매개변수가 필요합니다")
                    }
                    
                    let result = pow(base, exponent)
                    return [.text("결과: \(result)")]
                }
                
                private func _executeSqrt(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let value = args["value"]?.doubleValue else {
                        throw MCPError.invalidParams("value 매개변수가 필요합니다")
                    }
                    
                    if value < 0 {
                        throw MCPError.invalidParams("음수의 제곱근은 계산할 수 없습니다")
                    }
                    
                    let result = sqrt(value)
                    return [.text("결과: \(result)")]
                }

                private var _tools: [Tool] = []

                func getToolboxInfo() -> (name: String, description: String) {
                    return ("고급 계산기", "수학 계산 기능을 제공합니다")
                }

                func getTools() -> [Tool] {
                    return _tools
                }

                fileprivate mutating func _registerTool(_ tool: Tool) {
                    // 이미 등록된 동일한 이름의 도구가 있으면 중복 등록 방지
                    if !_tools.contains(where: { $0.name == tool.name }) {
                        _tools.append(tool)
                    }
                }

                func handleToolCall(name: String, arguments: [String: Value]?) throws -> [Tool.Content] {
                    switch name {
                    case "power":
                    return try _executePower(arguments: arguments)
                    case "sqrt":
                        return try _executeSqrt(arguments: arguments)
                    default:
                        throw MCPError.methodNotFound("Tool not found: \(name)")
                    }
                }

                private func _executePower(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 'power' 실행됨 (인자: \(arguments?.description ?? "없음"))")]
                }

                private func _executeSqrt(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 'sqrt' 실행됨 (인자: \(arguments?.description ?? "없음"))")]
                }
            }

            extension AdvancedCalculator: MCPToolbox {
            }
            """#
        }
    }
}
#endif
