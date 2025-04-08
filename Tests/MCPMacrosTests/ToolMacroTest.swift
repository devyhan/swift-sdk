// Import the macros for testing
import MCPMacros
import MacroTesting
import XCTest

final class ToolMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(record: .missing, macros: ["Tool": ToolMacro.self]) {
            super.invokeTest()
        }
    }

    func testToolMacro() {
        assertMacro {
            """
            struct MathToolbox {
                @Tool(description: "Adds two numbers together")
                func add(a: Int, b: Int) -> Int {
                    return a + b
                }
            }
            """
        } expansion: {
            """
            struct MathToolbox {
                func add(a: Int, b: Int) -> Int {
                    return a + b
                }

                struct addTool: MCPTool {
                    let toolbox: Any
                    
                    var name: String { "add" }
                    var description: String { "Adds two numbers together" }
                    var inputSchema: Value? {
                        return ["a": ["type": "object", "description": "Parameter a of type Int"], "b": ["type": "object", "description": "Parameter b of type Int"]]
                    }
                    
                    func call(arguments: [String: Value]?) async throws -> [Tool.Content] {
                        // In a real implementation, we would:
                        // 1. Extract parameters from arguments
                        // 2. Validate parameters
                        // 3. Call the actual method with the extracted parameters
                        // 4. Convert the result to Tool.Content
                        
                        // Placeholder implementation
                        return [.text("Called add - Not fully implemented")]
                    }
                }
            }
            """
        }
    }

    func testToolWithParamMacro() {
        assertMacro {
            """
            struct GreetingToolbox {
                @Tool(description: "Greets a person")
                func greet(@Param(description: "Name to greet") name: String) -> String {
                    return "Hello, \\(name)!"
                }
            }
            """
        } expansion: {
            """
            struct GreetingToolbox {
                func greet(name: String) -> String {
                    return "Hello, \\(name)!"
                }

                struct greetTool: MCPTool {
                    let toolbox: Any
                    
                    var name: String { "greet" }
                    var description: String { "Greets a person" }
                    var inputSchema: Value? {
                        return ["name": ["type": "string", "description": "Name to greet"]]
                    }
                    
                    func call(arguments: [String: Value]?) async throws -> [Tool.Content] {
                        // Implemented placeholder
                        return [.text("Called greet - Not fully implemented")]
                    }
                }
            }
            """
        }
    }
}
