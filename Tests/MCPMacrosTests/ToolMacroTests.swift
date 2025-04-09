#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class ToolMacroTests: MacroBaseTestCase {
    func testToolAccessor() {
        assertMacro {
            """
            struct MyTools {
                @Tool(description: "테스트 도구")
                var testTool: Tool
            }
            """
        } expansion: {
            """
            struct MyTools {
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
            }
            """
        }
    }
    
    func testToolWithCustomSchema() {
        assertMacro {
            """
            struct Calculator {
                @Tool(
                    description: "두 숫자를 더합니다",
                    schema: .object([
                        "a": .object(["type": .string("number")]),
                        "b": .object(["type": .string("number")])
                    ])
                )
                var add: Tool
            }
            """
        } expansion: {
            """
            struct Calculator {
                var add: Tool {
                    get {
                        let tool = Tool(
                            name: "add",
                            description: "두 숫자를 더합니다",
                            inputSchema: .object([
                                "a": .object(["type": .string("number")]),
                                "b": .object(["type": .string("number")])
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
            }
            """
        }
    }
}
#endif
