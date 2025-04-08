import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MCPMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ToolboxMacro.self,
        ToolMacro.self
    ]
}

struct MacroError: Error, CustomStringConvertible {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
}
