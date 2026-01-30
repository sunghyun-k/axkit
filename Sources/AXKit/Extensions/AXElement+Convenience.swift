import AppKit
@preconcurrency import ApplicationServices

extension AXElement {
    // MARK: - 애플리케이션 관련

    /// 현재 최상위(frontmost) 애플리케이션
    public static var frontmostApplication: AXElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        return application(pid: app.processIdentifier)
    }

    /// 실행 중인 모든 애플리케이션
    public static var runningApplications: [AXElement] {
        NSWorkspace.shared.runningApplications.compactMap { app in
            guard app.activationPolicy == .regular else { return nil }
            return application(pid: app.processIdentifier)
        }
    }

    // MARK: - 창 관련

    /// 애플리케이션의 모든 창
    public var windows: [AXElement] {
        attributeOrNil(AXAttribute.windows, as: [AXElement].self) ?? []
    }

    /// 애플리케이션의 메인 창
    public var mainWindow: AXElement? {
        attributeOrNil(AXAttribute.mainWindow, as: AXElement.self)
    }

    /// 애플리케이션의 포커스된 창
    public var focusedWindow: AXElement? {
        attributeOrNil(AXAttribute.focusedWindow, as: AXElement.self)
    }

    /// 포커스된 UI 요소
    public var focusedUIElement: AXElement? {
        attributeOrNil(AXAttribute.focusedUIElement, as: AXElement.self)
    }

    // MARK: - 메뉴 바

    /// 애플리케이션의 메뉴 바
    public var menuBar: AXElement? {
        attributeOrNil(AXAttribute.menuBar, as: AXElement.self)
    }

    // MARK: - 위치/크기 조작

    /// 요소 위치 설정
    public func setPosition(_ position: CGPoint) throws {
        try setPoint(AXAttribute.position, value: position)
    }

    /// 요소 크기 설정
    public func setFrameSize(_ size: CGSize) throws {
        try setSize(AXAttribute.size, value: size)
    }

    /// 요소 프레임 설정 (위치 + 크기)
    public func setFrame(_ rect: CGRect) throws {
        try setPosition(rect.origin)
        try setFrameSize(rect.size)
    }

    // MARK: - 창 조작

    /// 창을 화면 가운데로 이동
    public func centerOnScreen() throws {
        guard let screen = NSScreen.main, let frameSize else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - frameSize.width / 2
        let y = screenFrame.midY - frameSize.height / 2
        try setPosition(CGPoint(x: x, y: y))
    }

    /// 창 올리기 (앞으로 가져오기)
    public func raise() throws {
        try performAction(AXAction.raise)
    }

    /// 애플리케이션 활성화 여부
    public var isFrontmost: Bool {
        attributeOrNil(AXAttribute.frontmost, as: Bool.self) ?? false
    }

    /// 애플리케이션 숨김 여부
    public var isHidden: Bool {
        attributeOrNil(AXAttribute.hidden, as: Bool.self) ?? false
    }

    // MARK: - 요소 정보

    /// 최상위 UI 요소 (보통 창)
    public var topLevelUIElement: AXElement? {
        attributeOrNil(AXAttribute.topLevelUIElement, as: AXElement.self)
    }

    /// 역할 설명 (사람이 읽기 쉬운 형태)
    public var roleDescription: String? {
        attributeOrNil(AXAttribute.roleDescription, as: String.self)
    }

    /// 도움말 텍스트
    public var help: String? {
        attributeOrNil(AXAttribute.help, as: String.self)
    }

    /// 선택됨 여부
    public var isSelected: Bool {
        attributeOrNil(AXAttribute.selected, as: Bool.self) ?? false
    }

    // MARK: - 텍스트 관련

    /// 텍스트 필드의 문자 수
    public var numberOfCharacters: Int? {
        try? int(AXAttribute.numberOfCharacters)
    }

    /// 선택된 텍스트
    public var selectedText: String? {
        attributeOrNil(AXAttribute.selectedText, as: String.self)
    }

    /// 텍스트 값 (문자열로)
    public var stringValue: String? {
        value as? String
    }

    // MARK: - 디버깅

    /// 요소의 모든 속성과 값을 딕셔너리로 반환
    public func allAttributes() -> [String: Any] {
        guard let names = try? attributeNames() else { return [:] }
        var result: [String: Any] = [:]
        for name in names {
            var value: CFTypeRef?
            let error = AXUIElementCopyAttributeValue(ref, name as CFString, &value)
            if error == .success, let val = value {
                result[name] = val
            }
        }
        return result
    }

    /// 요소 트리를 문자열로 출력 (디버깅용)
    public func treeDescription(maxDepth: Int = 3, indent: Int = 0) -> String {
        let indentString = String(repeating: "  ", count: indent)
        var result = "\(indentString)\(description)\n"

        guard maxDepth > 0 else { return result }

        for child in children {
            result += child.treeDescription(maxDepth: maxDepth - 1, indent: indent + 1)
        }

        return result
    }
}
