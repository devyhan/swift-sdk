import SwiftSyntax

/// 클래스나 구조체를 MCP 도구 모음으로 표시합니다.
@attached(member, names: named(getMCPTools), named(getToolboxMetadata))
@attached(conformance)
public macro Toolbox(name: String, description: String) = #externalMacro(module: "MCPMacrosPlugin", type: "ToolboxMacro")

/// 메서드를 MCP 도구로 표시합니다.
@attached(peer, names: arbitrary)
public macro Tool(description: String) = #externalMacro(module: "MCPMacrosPlugin", type: "ToolMacro")

/// 매개변수를 도구 매개변수로 표시합니다.
@attached(peer)
public macro Param(description: String) = #externalMacro(module: "MCPMacrosPlugin", type: "ParamMacro")

/// MCP 도구 모음 프로토콜
public protocol MCPToolbox {
    /// 이 도구 모음에서 제공하는 모든 MCP 도구 목록을 반환합니다.
    func getMCPTools() -> [Tool]
    
    /// 도구 모음의 이름과 설명을 반환합니다.
    func getToolboxMetadata() -> (name: String, description: String)
}

/// 도구 처리를 위한 유틸리티 함수들
public enum ToolUtils {
    /// Tool.Content를 String으로 변환합니다.
    public static func contentToString(_ content: Tool.Content) -> String {
        switch content {
        case .text(let text):
            return text
        case .image(_, let mimeType, _):
            return "[Image: \(mimeType)]"
        case .resource(let uri, _, let text):
            return text ?? "[Resource: \(uri)]"
        }
    }
    
    /// 값을 Tool.Content로 변환합니다.
    public static func valueToContent<T>(_ value: T) -> Tool.Content {
        return .text(String(describing: value))
    }
}
