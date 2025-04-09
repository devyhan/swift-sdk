import Foundation

/// 클래스나 구조체에 MCP 도구 모음 기능을 추가하는 매크로입니다.
/// - Parameters:
///   - name: 도구 모음의 이름
///   - description: 도구 모음에 대한 설명
@attached(extension, conformances: MCPToolbox)
public macro Toolbox(name: String, description: String) = #externalMacro(
    module: "MCPMacros",
    type: "ToolboxMacro"
)

/// 속성을 MCP 도구로 변환하는 매크로입니다.
/// - Parameters:
///   - description: 도구에 대한 설명
///   - schema: 선택적으로 도구의 입력 스키마 지정
@attached(accessor)
public macro Tool(description: String, schema: Value? = nil) = #externalMacro(
    module: "MCPMacros",
    type: "ToolMacro"
)
