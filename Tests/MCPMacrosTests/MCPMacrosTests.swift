#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class MCPMacrosTests: MacroBaseTestCase {
    func testAllMacros() {
        // Tool 매크로만 테스트합니다
        assertMacro {
            """
            struct MCPToolsCollection {
                @Tool(description: "텍스트 처리 도구")
                var text: Tool
                
                @Tool(description: "데이터 변환 도구", 
                      inputSchema: .object([
                        "input": .object(["type": .string("string")]),
                        "format": .object(["type": .string("string"), "enum": .array([.string("json"), .string("xml"), .string("yaml")])])
                      ]))
                var convert: Tool
            }
            """
        } expansion: {
            """
            struct MCPToolsCollection {
                var text: Tool {
                    get {
                        let tool = Tool(
                            name: "text",
                            description: "텍스트 처리 도구",
                            inputSchema: nil
                        )
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
                        return tool
                    }
                }
            }
            """
        }
    }
}
#endif
