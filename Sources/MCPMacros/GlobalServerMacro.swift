import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// 전역 범위에서 서버를 생성하기 위한 매크로
public struct GlobalServerMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // 매크로 인자 추출
        let args = node.arguments
        guard let nameArg = args.first(where: { $0.label?.text == "name" })?.expression,
              let versionArg = args.first(where: { $0.label?.text == "version" })?.expression else {
            throw MacroError("@GlobalServer 매크로에는 name과 version 인자가 필요합니다")
        }
        
        // 선택적 인자 추출
        let capabilitiesArg = args.first(where: { $0.label?.text == "capabilities" })?.expression ?? ExprSyntax(stringLiteral: ".default")
        let configurationArg = args.first(where: { $0.label?.text == "configuration" })?.expression ?? ExprSyntax(stringLiteral: ".default")
        
        // 서버 생성 함수
        let createServerFunc = """
        /// 서버 인스턴스 생성
        func createServer() -> Server {
            let server = Server(
                name: \(nameArg.description),
                version: \(versionArg.description),
                capabilities: \(capabilitiesArg.description),
                configuration: \(configurationArg.description)
            )
            return server
        }
        """
        
        // 서버 시작 함수
        let startServerFunc = """
        /// 서버 시작
        /// - Parameter transport: 사용할 트랜스포트
        /// - Returns: 시작된 서버 인스턴스
        func startServer(transport: any Transport) async throws -> Server {
            let server = createServer()
            try await server.start(transport: transport)
            return server
        }
        """
        
        // 함수 등록 헬퍼 함수
        let setupHandlersFunc = """
        /// 서버 핸들러 설정
        /// - Parameter server: 설정할 서버 인스턴스
        func setupHandlers(server: Server) async {
            // 서버에 핸들러를 등록하는 코드 작성
            // 예: await server.withMethodHandler(ReadResource.self) { ... }
        }
        """
        
        return [
            DeclSyntax(stringLiteral: createServerFunc),
            DeclSyntax(stringLiteral: startServerFunc),
            DeclSyntax(stringLiteral: setupHandlersFunc)
        ]
    }
}
