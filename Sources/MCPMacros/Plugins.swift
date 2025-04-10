import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MCPMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        ToolMacro.self,
        ServerMacro.self
    ]
}
