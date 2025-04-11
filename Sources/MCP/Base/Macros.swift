import Foundation

/// Tool 매크로는 속성을 MCP 도구로 변환합니다.
/// 이 매크로는 Tool.swift에 정의된 Tool 구조체와 1:1 매칭되는 속성을 생성합니다.
///
/// - Parameters:
///   - name: 도구 이름
///   - description: 도구에 대한 설명
///   - inputSchema: 선택적으로 도구의 입력 스키마 지정
@attached(accessor)
public macro Tool(name: String? = nil, description: String, inputSchema: Value? = nil) = #externalMacro(
    module: "MCPMacros",
    type: "ToolMacro"
)

/// 타입을 MCP 서버로 변환합니다.
/// 이 매크로는 필요한 서버 메서드와 main 메서드를 자동 생성합니다.
///
/// 중요: @main 속성과 함께 사용할 경우 generateMain을 false로 설정해야 합니다.
/// 기본적으로 이 매크로는 static func main() 메서드를 생성합니다.
///
/// - Parameters:
///   - name: 서버 이름 (기본값: "MCPServer")
///   - version: 서버 버전 (기본값: "1.0.0")
///   - capabilities: 서버가 제공하는 기능 집합 (기본값: .init())
///   - generateMain: main() 메서드 생성 여부 (기본값: true)
@attached(member, names: arbitrary)
public macro Server(
    name: String = "MCPServer",
    version: String = "1.0.0",
    capabilities: Server.Capabilities = .init(),
    generateMain: Bool = true
) = #externalMacro(
    module: "MCPMacros",
    type: "ServerMacro"
)
