import Foundation
import Testing
import MCP

@Suite("Resource Integration Tests")
struct ResourceIntegrationTests {
    @Test("Resources basic usage")
    func testResourcesBasicUsage() throws {
        // 리소스를 정의하는 구조체
        struct DocumentResources {
            @Resource(uri: "test://example.txt")
            var simpleTextResource: Resource
            
            @Resource(
                name: "api-docs",
                description: "API 문서화 파일", 
                uri: "test://api/docs.md",
                mimeType: "text/markdown",
                metadata: ["version": "1.0"]
            )
            var apiDocumentation: Resource
        }
        
        // 리소스 구조체 인스턴스 생성
        let resources = DocumentResources()
        
        // 기본 리소스 확인
        let textResource = resources.simpleTextResource
        #expect(textResource.name == "simpleTextResource")
        #expect(textResource.uri == "test://example.txt")
        #expect(textResource.description == nil)
        #expect(textResource.mimeType == nil)
        
        // 상세 리소스 확인
        let docsResource = resources.apiDocumentation
        #expect(docsResource.name == "api-docs")
        #expect(docsResource.uri == "test://api/docs.md")
        #expect(docsResource.description == "API 문서화 파일")
        #expect(docsResource.mimeType == "text/markdown")
        #expect(docsResource.metadata?["version"] == "1.0")
    }
    
    @Test("Integration with server")
    func testServerIntegration() throws {
        // 서버와 리소스 통합 테스트를 위한 구조체
        struct TestResourceServer {
            @Resource(
                name: "welcome",
                description: "환영 메시지",
                uri: "test://welcome.txt",
                mimeType: "text/plain"
            )
            var welcomeResource: Resource
            
            // 서버에서 리소스 제공 방법 시뮬레이션
            func provideResources() -> [Resource] {
                return [welcomeResource]
            }
            
            // 리소스 내용 제공 시뮬레이션
            func getResourceContent(uri: String) -> Resource.Content? {
                if uri == welcomeResource.uri {
                    return Resource.Content.text("Welcome to MCP Server!", uri: uri)
                }
                return nil
            }
        }
        
        // 서버 인스턴스 생성
        let server = TestResourceServer()
        
        // 리소스 목록 확인
        let resources = server.provideResources()
        #expect(resources.count == 1)
        #expect(resources[0].name == "welcome")
        #expect(resources[0].uri == "test://welcome.txt")
        
        // 리소스 내용 확인
        let content = server.getResourceContent(uri: "test://welcome.txt")
        #expect(content != nil)
        
        if let textContent = content {
            #expect(textContent.text == "Welcome to MCP Server!")
            #expect(textContent.uri == "test://welcome.txt")
        } else {
            #expect(Bool(false), "예상된 텍스트 리소스가 없습니다")
        }
    }
}
