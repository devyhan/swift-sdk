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

/// Server 매크로는 구조체나 클래스를 MCP 서버로 변환합니다.
/// 이 매크로는 Server 인스턴스를 생성하고 도구와 핸들러를 자동으로 연결합니다.
///
/// - Parameters:
///   - name: 서버 이름
///   - version: 서버 버전
///   - capabilities: 서버 기능 (선택 사항)
///   - configuration: 서버 구성 (선택 사항)
@attached(member, names: named(server), named(initializeServer), named(startServer))
@attached(peer, names: named(createServer), named(startServer))
public macro Server(
    name: String,
    version: String,
    capabilities: ServerCapabilities = .default,
    configuration: ServerConfiguration = .default
) = #externalMacro(module: "MCPMacros", type: "ServerMacro")

/// 서버 기능 구성을 위한 타입 별칭
public typealias ServerCapabilities = Server.Capabilities

/// 서버 구성을 위한 타입 별칭
public typealias ServerConfiguration = Server.Configuration

/// GlobalServer 매크로는 전역 범위에서 MCP 서버를 생성합니다.
/// 이 매크로는 구조체나 클래스 없이 서버를 생성하고 관리하는 함수들을 제공합니다.
///
/// - Parameters:
///   - name: 서버 이름
///   - version: 서버 버전
///   - capabilities: 서버 기능 (선택 사항)
///   - configuration: 서버 구성 (선택 사항)
@freestanding(declaration, names: named(createServer), named(startServer), named(setupHandlers))
public macro GlobalServer(
    name: String,
    version: String,
    capabilities: ServerCapabilities = .default,
    configuration: ServerConfiguration = .default
) = #externalMacro(
    module: "MCPMacros",
    type: "GlobalServerMacro"
)

/// Resource 매크로는 속성을 MCP 리소스로 변환합니다.
/// 이 매크로는 Resource.swift에 정의된 Resource 구조체와 1:1 매칭되는 속성을 생성합니다.
///
/// - Parameters:
///   - name: 리소스 이름 (옵션, 지정하지 않으면 변수 이름 사용)
///   - description: 리소스에 대한 설명 (옵션)
///   - uri: 리소스 URI (필수)
///   - mimeType: 리소스의 MIME 타입 (옵션)
///   - metadata: 리소스의 메타데이터 (옵션)
@attached(accessor)
public macro Resource(
    name: String? = nil, 
    description: String? = nil, 
    uri: String, 
    mimeType: String? = nil,
    metadata: [String: String]? = nil
) = #externalMacro(
    module: "MCPMacros",
    type: "ResourceMacro"
)
