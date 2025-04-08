#if canImport(MCPMacros)
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

            """
        } expansion: {
            """

            """
        }
    }

    func testToolWithParamMacro() {
        assertMacro {
            """

            """
        } expansion: {
            """

            """
        }
    }
}
#endif
