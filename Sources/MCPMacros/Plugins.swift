import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// MCP 매크로 플러그인 진입점
@main
struct MCPMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ToolboxMacro.self,
        ToolMacro.self,
        ParamMacro.self
    ]
}

struct MacroError: Error, CustomStringConvertible {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
}
