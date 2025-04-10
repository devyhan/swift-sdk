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
                var simpleResource: Resource
            }
            """
        } expansion: {
            """
            struct MyResources {
                var simpleResource: Resource {
                    get {
                        let resource = Resource(
                            name: "simpleResource",
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
                @Resource(name: "readme", uri: "test://readme.md")
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
    
    func testResourceWithAllParameters() {
        assertMacro {
            """
            struct DocumentStore {
                @Resource(
                    name: "api-docs",
                    description: "API 문서화 파일", 
                    uri: "test://api/docs.md",
                    mimeType: "text/markdown",
                    metadata: ["version": "1.0", "author": "MCP Team"]
                )
                var apiDocumentation: Resource
            }
            """
        } expansion: {
            """
            struct DocumentStore {
                var apiDocumentation: Resource {
                    get {
                        let resource = Resource(
                            name: "api-docs",
                            uri: "test://api/docs.md",
                            description: "API 문서화 파일",
                            mimeType: "text/markdown",
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
