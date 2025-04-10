#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

class MacroBaseTestCase: XCTestCase {
    override func invokeTest() {
        MacroTesting.withMacroTesting(
            record: false, // 테스트 기록 모드 비활성화
            macros: [
                ToolMacro.self,
                ServerMacro.self,
                ResourceMacro.self
            ]
        ) {
            super.invokeTest()
        }
    }
}
#endif
