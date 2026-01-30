import ApplicationServices

/// 접근성 권한 관리
public enum AXPermission: Sendable {
    /// 접근성 권한이 부여되었는지 확인
    public static var isGranted: Bool {
        AXIsProcessTrusted()
    }

    /// 접근성 권한 요청 다이얼로그 표시
    /// - Parameter prompt: true이면 시스템 다이얼로그 표시
    /// - Returns: 권한 부여 여부
    @discardableResult
    public static func request(prompt: Bool = true) -> Bool {
        // kAXTrustedCheckOptionPrompt의 실제 값은 "AXTrustedCheckOptionPrompt"
        let options = ["AXTrustedCheckOptionPrompt": prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// 권한이 있는지 확인하고 없으면 throw
    /// - Throws: `AXKitError.permissionDenied` 권한이 없는 경우
    public static func ensureGranted() throws {
        guard isGranted else {
            throw AXKitError.permissionDenied
        }
    }
}
