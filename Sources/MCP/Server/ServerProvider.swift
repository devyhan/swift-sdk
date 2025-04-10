import Foundation

/// MCP 서버 프로바이더 프로토콜
/// @Server 매크로가 적용된 타입에서 구현하여 파일 경계를 넘어 접근할 수 있도록 합니다.
public protocol ServerProvider {
    /// 서버를 생성하고 시작하는 래퍼 메서드
    /// - Parameter transport: 서버 통신에 사용할 전송 계층
    /// - Returns: 시작된 서버 인스턴스
    func createAndStartServer(transport: any Transport) async throws -> Server
}

/// 모든 서버 프로바이더에 대한 기본 구현
extension ServerProvider {
    /// 서버 생성 및 초기화 함수
    /// - Parameter initializeHook: 초기화 시 실행할 선택적 hook
    /// - Returns: 생성된 서버 인스턴스
    public func createServerWithInitHook(
        initializeHook: (@Sendable (Client.Info, Client.Capabilities) async throws -> Void)? = nil
    ) async throws -> (server: Server, startFunc: (any Transport) async throws -> Void) {
        // 이 메서드는 하위 클래스에서 재정의하여 구현해야 합니다.
        // @Server 매크로가 생성한 createServer() 함수를 호출
        fatalError("이 메서드는 하위 클래스에서 재정의해야 합니다.")
    }
    
    /// 서버를 생성하고 시작하는 편의 메서드
    /// - Parameters:
    ///   - transport: 서버 통신에 사용할 전송 계층
    ///   - initializeHook: 초기화 시 실행할 선택적 hook
    /// - Returns: 시작된 서버 인스턴스
    public func createAndStartServer(
        transport: any Transport,
        initializeHook: (@Sendable (Client.Info, Client.Capabilities) async throws -> Void)? = nil
    ) async throws -> Server {
        // 이 메서드는 하위 클래스에서 재정의하여 구현해야 합니다.
        fatalError("이 메서드는 @Server 매크로가 적용된 타입에서 구현해야 합니다")
    }
}
