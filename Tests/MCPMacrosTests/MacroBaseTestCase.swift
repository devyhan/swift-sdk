#if canImport(MCPMacros)
    import MCPMacros
    import MacroTesting
    import SwiftSyntaxMacros
    import SwiftSyntaxMacrosTestSupport
    import XCTest

    class MacroBaseTestCase: XCTestCase {
        override func invokeTest() {
            MacroTesting.withMacroTesting(
                record: false,
                macros: [
                    ToolMacro.self,
                    ServerMacro.self
                ]
            ) {
                super.invokeTest()
            }
        }
    }
#endif
