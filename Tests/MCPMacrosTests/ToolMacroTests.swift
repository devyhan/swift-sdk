#if canImport(MCPMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

@testable import MCPMacros

final class ToolMacrosTests: MacroBaseTestCase {
    func testToolMacro() {
        assertMacro {
            """
            @Tool(description: "테스트 도구입니다")
            var testTool: Tool
            """
        } expansion: {
            """
            var testTool: Tool {
                get {
                    return Tool(
                        name: "testTool",
                        description: "테스트 도구입니다",
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
                }
            }
            """
        }
    }
    
    func testToolboxMacro() {
        assertMacro {
            """
            @Toolbox(name: "테스트 도구 모음", description: "테스트용 도구 모음입니다")
            struct TestToolbox {
                @Tool(description: "첫 번째 도구")
                var tool1: Tool
            }
            """
        } expansion: {
            """
            struct TestToolbox {
                @Tool(description: "첫 번째 도구")
                var tool1: Tool
            
                func getToolboxInfo() -> (name: String, description: String) {
                    return ("테스트 도구 모음", "테스트용 도구 모음입니다")
                }
            
                func getTools() -> [Tool] {
                    var tools: [Tool] = []
                    for method in _getToolDefinitionMethods() {
                        if let tool = self.perform(method)?.takeRetainedValue() as? Tool {
                            tools.append(tool)
                        }
                    }
                    return tools
                }
            
                private func _getToolDefinitionMethods() -> [Selector] {
                    var methods: [Selector] = []
                    let mirror = Mirror(reflecting: self)
                    for child in mirror.children {
                        if let methodName = child.label, methodName.hasPrefix("_toolDefinition_") {
                            if let selector = NSSelectorFromString(methodName) {
                                methods.append(selector)
                            }
                        }
                    }
                    return methods
                }
            
                func handleToolCall(name: String, arguments: [String: Value]?) throws -> [Tool.Content] {
                    switch name {
                    case "tool1":
                        return try _executeTool1(arguments: arguments)
                    default:
                        throw MCPError.methodNotFound("Tool not found: \\(name)")
                    }
                }
            }
            """
        }
    }
}
#endif
