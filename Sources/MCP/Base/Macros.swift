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
