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
            ToolMacro.self,
            ToolboxMacro.self
        ]
      ) {
        super.invokeTest()
      }
    }
  }
#endif
