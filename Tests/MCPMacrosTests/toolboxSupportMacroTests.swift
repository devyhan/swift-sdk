#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class ToolboxSupportMacroTests: MacroBaseTestCase {
    // 툴박스 확장 테스트
    func testToolboxExtensionOnly() {
        // 단일 매크로 테스트
        assertMacro {
            """
            @Toolbox(name: "테스트 도구 모음", description: "테스트용 도구 모음입니다")
            struct TestTools {}
            """
        } expansion: {
            #"""
            struct TestTools {

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

                    default:
                        throw MCPError.methodNotFound("Tool not found: \(name)")
                    }
                }
            }

            extension TestTools: MCPToolbox {
            }
            """#
        }
    }
    
    // 툴 확장 테스트
    func testToolGetterOnly() {
        // 단일 매크로 테스트
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
}
#endif
