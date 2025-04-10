#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class SimpleMacroTests: MacroBaseTestCase {
    // Tool 매크로의 가장 기본적인 기능만 테스트
    func testSimpleTool() {
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
}
#endif