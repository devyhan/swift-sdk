#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class IntegrationTests: MacroBaseTestCase {
    func testToolWithVariousConfigurations() {
        assertMacro {
            """
            struct AdvancedTools {
                // 기본 도구
                @Tool(description: "간단한 텍스트 처리 도구")
                var text: Tool
                
                // 커스텀 이름을 사용하는 도구
                @Tool(name: "formatJson", description: "JSON 데이터 포맷팅")
                var jsonFormatter: Tool
                
                // 입력 스키마가 있는 도구
                @Tool(
                    description: "데이터 변환 도구", 
                    inputSchema: .object([
                        "input": .object(["type": .string("string")]),
                        "format": .object([
                            "type": .string("string"), 
                            "enum": .array([
                                .string("json"), 
                                .string("xml"), 
                                .string("yaml")
                            ])
                        ])
                    ])
                )
                var convert: Tool
            }
            """
        } expansion: {
            """
            struct AdvancedTools {
                // 기본 도구
                var text: Tool {
                    get {
                        let tool = Tool(
                            name: "text",
                            description: "간단한 텍스트 처리 도구",
                            inputSchema: nil
                        )
                        return tool
                    }
                }
                
                // 커스텀 이름을 사용하는 도구
                var jsonFormatter: Tool {
                    get {
                        let tool = Tool(
                            name: "formatJson",
                            description: "JSON 데이터 포맷팅",
                            inputSchema: nil
                        )
                        return tool
                    }
                }
                
                // 입력 스키마가 있는 도구
                var convert: Tool {
                    get {
                        let tool = Tool(
                            name: "convert",
                            description: "데이터 변환 도구",
                            inputSchema: .object([
                                "input": .object(["type": .string("string")]),
                                "format": .object([
                                    "type": .string("string"),
                                    "enum": .array([
                                        .string("json"),
                                        .string("xml"),
                                        .string("yaml")
                                    ])
                                ])
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
