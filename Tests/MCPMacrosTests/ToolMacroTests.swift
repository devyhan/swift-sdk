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
                            inputSchema: nil
                        )
                        return tool
                    }
                }
            }
            """
        }
    }
    
    func testToolWithCustomName() {
        assertMacro {
            """
            struct Calculator {
                @Tool(name: "addition", description: "두 숫자를 더합니다")
                var add: Tool
            }
            """
        } expansion: {
            """
            struct Calculator {
                var add: Tool {
                    get {
                        let tool = Tool(
                            name: "addition",
                            description: "두 숫자를 더합니다",
                            inputSchema: nil
                        )
                        return tool
                    }
                }
            }
            """
        }
    }
    
    func testToolWithInputSchema() {
        assertMacro {
            """
            struct Calculator {
                @Tool(
                    description: "두 숫자를 더합니다",
                    inputSchema: .object([
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
                        return tool
                    }
                }
            }
            """
        }
    }
}
#endif
