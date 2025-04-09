#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class ToolboxMacroTests: MacroBaseTestCase {
    func testToolboxExtension() {
        assertMacro {
            """
            @Toolbox(name: "테스트 도구 모음", description: "테스트용 도구 모음입니다")
            struct TestTools {
                @Tool(description: "테스트 도구")
                var testTool: Tool
            }
            """
        } expansion: {
            #"""
            struct TestTools {
                var testTool: Tool {
                    get {
                        let tool = Tool(
                            name: "testTool",
                            description: "테스트 도구",
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

                private var _tools: [Tool] = []

                func getToolboxInfo() -> (name: String, description: String) {
                    return ("테스트 도구 모음", "테스트용 도구 모음입니다")
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
                    case "testTool":
                    return try _executeTesttool(arguments: arguments)
                    default:
                        throw MCPError.methodNotFound("Tool not found: \(name)")
                    }
                }

                private func _executeTesttool(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 'testTool' 실행됨 (인자: \(arguments?.description ?? "없음"))")]
                }
            }

            extension TestTools: MCPToolbox {
            }
            """#
        }
    }
    
    func testToolboxWithMultipleTools() {
        assertMacro {
            """
            @Toolbox(name: "계산기", description: "기본 계산 기능을 제공합니다")
            struct Calculator {
                @Tool(description: "두 숫자를 더합니다")
                var add: Tool
                
                @Tool(description: "두 숫자를 곱합니다")
                var multiply: Tool
            }
            """
        } expansion: {
            #"""
            struct Calculator {
                var add: Tool {
                    get {
                        let tool = Tool(
                            name: "add",
                            description: "두 숫자를 더합니다",
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

                var multiply: Tool {
                    get {
                        let tool = Tool(
                            name: "multiply",
                            description: "두 숫자를 곱합니다",
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

                private var _tools: [Tool] = []

                func getToolboxInfo() -> (name: String, description: String) {
                    return ("계산기", "기본 계산 기능을 제공합니다")
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
                    case "add":
                    return try _executeAdd(arguments: arguments)
                    case "multiply":
                        return try _executeMultiply(arguments: arguments)
                    default:
                        throw MCPError.methodNotFound("Tool not found: \(name)")
                    }
                }

                private func _executeAdd(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 'add' 실행됨 (인자: \(arguments?.description ?? "없음"))")]
                }

                private func _executeMultiply(arguments: [String: Value]?) throws -> [Tool.Content] {
                    // 기본 구현 - 실제 구현에서 재정의해야 함
                    return [.text("도구 'multiply' 실행됨 (인자: \(arguments?.description ?? "없음"))")]
                }
            }

            extension Calculator: MCPToolbox {
            }
            """#
        }
    }
}
#endif
