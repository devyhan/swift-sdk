import Foundation
import Testing
import MCP

@Suite("Resource Integration Tests")
struct ResourceIntegrationTests {
    @Test("Resources basic usage")
    func testResourcesBasicUsage() throws {
        class DocumentResources {
            @Resource(uri: "test://example.txt")
            var text: Resource
            
            @Resource(
                name: "documentation",
                description: "API 문서", 
                uri: "test://api/docs.md",
                mimeType: "text/markdown"
            )
            var apiDocs: Resource
            
            // 리소스 내용 추출을 위한 헬퍼 메서드 - 실제 서버에서는 ReadResource 핸들러로 연결됨
            func getTextResourceContent() -> String {
                return "이것은 예제 텍스트 리소스입니다."
            }
            
            func getApiDocsContent() -> String {
                return "# API 문서\n\n## 엔드포인트\n\n- GET /api/v1/users\n- POST /api/v1/users"
            }
        }
        
        let resources = DocumentResources()
        
        // 리소스 검증
        let textResource = resources.text
        #expect(textResource.name == "text")
        #expect(textResource.uri == "test://example.txt")
        #expect(textResource.description == nil)
        #expect(textResource.mimeType == nil)
        
        let apiDocsResource = resources.apiDocs
        #expect(apiDocsResource.name == "documentation")
        #expect(apiDocsResource.description == "API 문서")
        #expect(apiDocsResource.uri == "test://api/docs.md")
        #expect(apiDocsResource.mimeType == "text/markdown")
        
        // 리소스 내용 검증 (실제로는 서버에서 읽어옴)
        let textContent = resources.getTextResourceContent()
        #expect(textContent == "이것은 예제 텍스트 리소스입니다.")
        
        let apiDocsContent = resources.getApiDocsContent()
        #expect(apiDocsContent.starts(with: "# API 문서"))
    }
    
    @Test("Resources with Server integration")
    func testResourcesWithServer() throws {
        struct DocumentServer {
            @Resource(uri: "test://example.txt", mimeType: "text/plain")
            var textResource: Resource
            
            @Tool(description: "텍스트를 처리하는 도구")
            var textProcessor: Tool
            
            func textProcessorHandler(arguments: [String: Value]?) throws -> [Tool.Content] {
                // 리소스를 사용해 텍스트 처리 시뮬레이션
                let resourceContent = "예제 리소스의 내용입니다."
                
                if let op = arguments?["operation"]?.stringValue {
                    switch op {
                    case "uppercase":
                        return [.text(resourceContent.uppercased())]
                    case "lowercase":
                        return [.text(resourceContent.lowercased())]
                    default:
                        return [.text(resourceContent)]
                    }
                }
                
                return [.text(resourceContent)]
            }
        }
        
        let server = DocumentServer()
        
        // 리소스 검증
        #expect(server.textResource.name == "textResource")
        #expect(server.textResource.uri == "test://example.txt")
        #expect(server.textResource.mimeType == "text/plain")
        
        // 도구와 함께 사용
        let result = try server.textProcessorHandler(arguments: ["operation": .string("uppercase")])
        if case .text(let text) = result.first {
            #expect(text == "예제 리소스의 내용입니다.".uppercased())
        } else {
            #expect(Bool(false), "예상된 텍스트 결과가 없습니다")
        }
    }
}
