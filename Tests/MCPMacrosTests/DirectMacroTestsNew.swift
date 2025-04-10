#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class DirectMacroTests: MacroBaseTestCase {
    // Tool 매크로 테스트
    func testTool() {
        assertMacro {
            """
            struct SimpleTools {
                @Tool(description: "간단한 도구")
                var simple: Tool
            }
            """
        } expansion: {
            """
            struct SimpleTools {
                var simple: Tool {
                    get {
                        let tool = Tool(
                            name: "simple",
                            description: "간단한 도구",
                            inputSchema: nil
                        )
                        return tool
                    }
                }
            }
            """
        }
    }
    
    // 커스텀 이름을 사용하는 Tool 테스트
    func testToolWithCustomName() {
        assertMacro {
            """
            struct Calculator {
                @Tool(name: "customAddition", description: "수학 더하기 도구")
                var add: Tool
            }
            """
        } expansion: {
            """
            struct Calculator {
                var add: Tool {
                    get {
                        let tool = Tool(
                            name: "customAddition",
                            description: "수학 더하기 도구",
                            inputSchema: nil
                        )
                        return tool
                    }
                }
            }
            """
        }
    }
    
    // 스키마와 함께 Tool 테스트
    func testToolWithSchema() {
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
