#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class MCPMacrosTests: MacroBaseTestCase {
    func testAllMacros() {
        // 모든 매크로 확장을 테스트합니다.
        assertMacro {
            """
            @Toolbox(name: "MCP 도구 모음", description: "Model Context Protocol 도구 모음")
            class MCPToolsCollection {
                @Tool(description: "텍스트 처리 도구")
                var text: Tool
                
                @Tool(description: "데이터 변환 도구", 
                      schema: .object([
                        "input": .object(["type": .string("string")]),
                        "format": .object(["type": .string("string"), "enum": .array([.string("json"), .string("xml"), .string("yaml")])])
                      ]))
                var convert: Tool
                
                private func _executeText(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let text = args["text"]?.stringValue else {
                        throw MCPError.invalidParams("text 매개변수가 필요합니다")
                    }
                    
                    return [.text("처리된 텍스트: \\(text)")]
                }
                
                private func _executeConvert(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let input = args["input"]?.stringValue,
                          let format = args["format"]?.stringValue else {
                        throw MCPError.invalidParams("input과 format 매개변수가 필요합니다")
                    }
                    
                    return [.text("\\(format) 형식으로 변환됨: \\(input)")]
                }
            }
            """
        } expansion: {
            #"""
            class MCPToolsCollection {
                var text: Tool {
                    get {
                        let tool = Tool(
                            name: "text",
                            description: "텍스트 처리 도구",
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

                var convert: Tool {
                    get {
                        let tool = Tool(
                            name: "convert",
                            description: "데이터 변환 도구",
                            inputSchema: .object([
                                "input": .object(["type": .string("string")]),
                                "format": .object(["type": .string("string"), "enum": .array([.string("json"), .string("xml"), .string("yaml")])])
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
                
                private func _executeText(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let text = args["text"]?.stringValue else {
                        throw MCPError.invalidParams("text 매개변수가 필요합니다")
                    }
                    
                    return [.text("처리된 텍스트: \(text)")]
                }
                
                private func _executeConvert(arguments: [String: Value]?) throws -> [Tool.Content] {
                    guard let args = arguments,
                          let input = args["input"]?.stringValue,
                          let format = args["format"]?.stringValue else {
                        throw MCPError.invalidParams("input과 format 매개변수가 필요합니다")
                    }
                    
                    return [.text("\(format) 형식으로 변환됨: \(input)")]
                }

                private var _tools: [Tool] = []

                func getToolboxInfo() -> (name: String, description: String) {
                    return ("MCP 도구 모음", "Model Context Protocol 도구 모음")
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
                    case "text":
                    return try _executeText(arguments: arguments)
                    case "convert":
                        return try _executeConvert(arguments: arguments)
                    default:
                        throw MCPError.methodNotFound("Tool not found: \(name)")
                    }
                }

                private func _executeText(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 'text' 실행됨 (인자: \(arguments?.description ?? "없음"))")]
                }

                private func _executeConvert(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 'convert' 실행됨 (인자: \(arguments?.description ?? "없음"))")]
                }
            }

            extension MCPToolsCollection: MCPToolbox {
            }
            """#
        }
    }
}
#endif
