#if canImport(MCPMacros)
import MCPMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class ResourceMacroTests: MacroBaseTestCase {
    func testResourceAccessor() {
        assertMacro {
            """
            struct MyResources {
                @Resource(uri: "test://example.txt")
                var textResource: Resource
            }
            """
        } expansion: {
            """
            struct MyResources {
                var textResource: Resource {
                    get {
                        let resource = Resource(
                            name: "textResource",
                            uri: "test://example.txt",
                            description: nil,
                            mimeType: nil,
                            metadata: nil
                        )
                        return resource
                    }
                }
            }
            """
        }
    }
    
    func testResourceWithCustomName() {
        assertMacro {
            """
            struct Documents {
                @Resource(name: "readme", uri: "test://readme.md", mimeType: "text/markdown")
                var readmeDoc: Resource
            }
            """
        } expansion: {
            """
            struct Documents {
                var readmeDoc: Resource {
                    get {
                        let resource = Resource(
                            name: "readme",
                            uri: "test://readme.md",
                            description: nil,
                            mimeType: "text/markdown",
                            metadata: nil
                        )
                        return resource
                    }
                }
            }
            """
        }
    }
    
    func testResourceWithAllParameters() {
        assertMacro {
            """
            struct Documents {
                @Resource(
                    name: "api-spec",
                    description: "API Specification Document",
                    uri: "test://api/spec.json",
                    mimeType: "application/json",
                    metadata: ["version": "1.0", "author": "MCP Team"]
                )
                var apiSpec: Resource
            }
            """
        } expansion: {
            """
            struct Documents {
                var apiSpec: Resource {
                    get {
                        let resource = Resource(
                            name: "api-spec",
                            uri: "test://api/spec.json",
                            description: "API Specification Document",
                            mimeType: "application/json",
                            metadata: ["version": "1.0", "author": "MCP Team"]
                        )
                        return resource
                    }
                }
            }
            """
        }
    }
}
#endif