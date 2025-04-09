#if canImport(MCPMacros)
    import MCPMacros
    import MacroTesting
    import SwiftSyntaxMacros
    import SwiftSyntaxMacrosTestSupport
    import XCTest

    class MacroBaseTestCase: XCTestCase {
        override func invokeTest() {
            MacroTesting.withMacroTesting(
                //isRecording: true,
                macros: [
                
                ]
            ) {
                super.invokeTest()
            }
        }
    }
#endif
