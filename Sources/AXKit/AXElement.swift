import AppKit
@preconcurrency import ApplicationServices

/// AXUIElement의 Swift 래퍼
public final class AXElement: @unchecked Sendable {
    /// 내부 AXUIElement 참조
    public let ref: AXUIElement

    /// AXUIElement로 초기화
    public init(_ ref: AXUIElement) {
        self.ref = ref
    }

    // MARK: - 팩토리 메서드

    /// 시스템 전역 요소 생성
    public static func systemWide() -> AXElement {
        AXElement(AXUIElementCreateSystemWide())
    }

    /// 특정 PID의 애플리케이션 요소 생성
    public static func application(pid: pid_t) -> AXElement {
        AXElement(AXUIElementCreateApplication(pid))
    }

    /// 번들 ID로 애플리케이션 요소 생성
    /// - Parameter bundleIdentifier: 앱의 번들 ID
    /// - Returns: 애플리케이션 요소
    /// - Throws: `AXKitError.applicationNotFound` 앱을 찾을 수 없는 경우
    public static func application(bundleIdentifier: String) throws -> AXElement {
        guard let app = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier).first
        else {
            throw AXKitError.applicationNotFound(bundleIdentifier: bundleIdentifier)
        }
        return application(pid: app.processIdentifier)
    }

    /// 화면 좌표의 요소 가져오기
    /// - Parameters:
    ///   - point: 화면 좌표
    ///   - root: 탐색 시작 요소 (nil이면 시스템 전역)
    /// - Returns: 해당 위치의 요소
    /// - Throws: 요소를 찾을 수 없는 경우
    public static func element(at point: CGPoint, from root: AXElement? = nil) throws -> AXElement {
        let rootElement = root ?? systemWide()
        var elementRef: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(
            rootElement.ref,
            Float(point.x),
            Float(point.y),
            &elementRef,
        )
        try AXKitError.check(error)
        guard let element = elementRef else {
            throw AXKitError.elementNotFound(description: "위치 (\(point.x), \(point.y))에 요소 없음")
        }
        return AXElement(element)
    }

    // MARK: - 속성 읽기 (제네릭)

    /// 속성 값 읽기
    /// - Parameters:
    ///   - attribute: 속성 이름
    ///   - type: 기대하는 타입
    /// - Returns: 속성 값
    /// - Throws: 속성 접근 실패 또는 타입 불일치
    public func attribute<T>(_ attribute: String, as type: T.Type) throws -> T {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(ref, attribute as CFString, &value)
        try AXKitError.check(error, attribute: attribute)

        guard let result = value else {
            throw AXKitError.attributeNil(attribute: attribute)
        }

        // AXUIElement -> AXElement 변환
        if type == AXElement.self {
            guard CFGetTypeID(result) == AXUIElementGetTypeID() else {
                throw AXKitError.typeMismatch(
                    expected: "AXUIElement",
                    actual: String(describing: CFGetTypeID(result)),
                )
            }
            return AXElement(result as! AXUIElement) as! T
        }

        // [AXUIElement] -> [AXElement] 변환
        if type == [AXElement].self {
            guard let array = result as? [AXUIElement] else {
                throw AXKitError.typeMismatch(
                    expected: "[AXUIElement]",
                    actual: String(describing: Swift.type(of: result)),
                )
            }
            return array.map { AXElement($0) } as! T
        }

        // CGPoint 변환
        if type == CGPoint.self {
            var point = CGPoint.zero
            guard AXValueGetValue(result as! AXValue, .cgPoint, &point) else {
                throw AXKitError.typeMismatch(expected: "CGPoint", actual: "AXValue")
            }
            return point as! T
        }

        // CGSize 변환
        if type == CGSize.self {
            var size = CGSize.zero
            guard AXValueGetValue(result as! AXValue, .cgSize, &size) else {
                throw AXKitError.typeMismatch(expected: "CGSize", actual: "AXValue")
            }
            return size as! T
        }

        // CGRect 변환
        if type == CGRect.self {
            var rect = CGRect.zero
            guard AXValueGetValue(result as! AXValue, .cgRect, &rect) else {
                throw AXKitError.typeMismatch(expected: "CGRect", actual: "AXValue")
            }
            return rect as! T
        }

        // 일반 타입 변환
        guard let typedValue = result as? T else {
            throw AXKitError.typeMismatch(
                expected: String(describing: T.self),
                actual: String(describing: Swift.type(of: result)),
            )
        }
        return typedValue
    }

    /// 속성 값 읽기 (실패 시 nil 반환)
    public func attributeOrNil<T>(_ attribute: String, as type: T.Type) -> T? {
        try? self.attribute(attribute, as: type)
    }

    // MARK: - 타입별 속성 읽기

    /// 문자열 속성 읽기
    public func string(_ attribute: String) throws -> String {
        try self.attribute(attribute, as: String.self)
    }

    /// 불리언 속성 읽기
    public func bool(_ attribute: String) throws -> Bool {
        try self.attribute(attribute, as: Bool.self)
    }

    /// 정수 속성 읽기
    public func int(_ attribute: String) throws -> Int {
        // CFNumber는 다양한 타입으로 반환될 수 있음
        if let intValue = try? self.attribute(attribute, as: Int.self) {
            return intValue
        }
        // NSNumber로 시도
        let number = try self.attribute(attribute, as: NSNumber.self)
        return number.intValue
    }

    /// CGPoint 속성 읽기
    public func point(_ attribute: String) throws -> CGPoint {
        try self.attribute(attribute, as: CGPoint.self)
    }

    /// CGSize 속성 읽기
    public func size(_ attribute: String) throws -> CGSize {
        try self.attribute(attribute, as: CGSize.self)
    }

    /// CGRect 속성 읽기 (position + size)
    public func rect(_ positionAttribute: String, _ sizeAttribute: String) throws -> CGRect {
        let origin = try point(positionAttribute)
        let size = try size(sizeAttribute)
        return CGRect(origin: origin, size: size)
    }

    /// 단일 요소 속성 읽기
    public func element(_ attribute: String) throws -> AXElement {
        try self.attribute(attribute, as: AXElement.self)
    }

    /// 요소 배열 속성 읽기
    public func elements(_ attribute: String) throws -> [AXElement] {
        try self.attribute(attribute, as: [AXElement].self)
    }

    /// 지원하는 속성 이름 목록
    public func attributeNames() throws -> [String] {
        var names: CFArray?
        let error = AXUIElementCopyAttributeNames(ref, &names)
        try AXKitError.check(error)
        return (names as? [String]) ?? []
    }

    /// 속성 쓰기 가능 여부 확인
    public func isAttributeSettable(_ attribute: String) throws -> Bool {
        var settable: DarwinBoolean = false
        let error = AXUIElementIsAttributeSettable(ref, attribute as CFString, &settable)
        try AXKitError.check(error)
        return settable.boolValue
    }

    // MARK: - 속성 쓰기

    /// 속성 값 설정
    public func setAttribute(_ attribute: String, value: CFTypeRef) throws {
        let error = AXUIElementSetAttributeValue(ref, attribute as CFString, value)
        try AXKitError.check(error)
    }

    /// CGPoint 속성 설정
    public func setPoint(_ attribute: String, value: CGPoint) throws {
        var point = value
        guard let axValue = AXValueCreate(.cgPoint, &point) else {
            throw AXKitError.typeMismatch(expected: "AXValue", actual: "CGPoint creation failed")
        }
        try setAttribute(attribute, value: axValue)
    }

    /// CGSize 속성 설정
    public func setSize(_ attribute: String, value: CGSize) throws {
        var size = value
        guard let axValue = AXValueCreate(.cgSize, &size) else {
            throw AXKitError.typeMismatch(expected: "AXValue", actual: "CGSize creation failed")
        }
        try setAttribute(attribute, value: axValue)
    }

    // MARK: - 편의 프로퍼티

    /// 요소의 역할
    public var role: String? {
        attributeOrNil(AXAttribute.role, as: String.self)
    }

    /// 요소의 서브롤
    public var subrole: String? {
        attributeOrNil(AXAttribute.subrole, as: String.self)
    }

    /// 요소의 제목
    public var title: String? {
        attributeOrNil(AXAttribute.title, as: String.self)
    }

    /// 요소의 값 (Any)
    public var value: Any? {
        var result: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(ref, AXAttribute.value as CFString, &result)
        guard error == .success else { return nil }
        return result
    }

    /// 요소의 설명
    public var axDescription: String? {
        attributeOrNil(AXAttribute.axDescription, as: String.self)
    }

    /// 요소의 식별자
    public var identifier: String? {
        attributeOrNil(AXAttribute.identifier, as: String.self)
    }

    /// 요소 활성화 여부
    public var isEnabled: Bool {
        attributeOrNil(AXAttribute.enabled, as: Bool.self) ?? true
    }

    /// 요소 포커스 여부
    public var isFocused: Bool {
        attributeOrNil(AXAttribute.focused, as: Bool.self) ?? false
    }

    /// 요소의 위치
    public var position: CGPoint? {
        try? point(AXAttribute.position)
    }

    /// 요소의 크기
    public var frameSize: CGSize? {
        try? size(AXAttribute.size)
    }

    /// 요소의 프레임 (position + size)
    public var frame: CGRect? {
        guard let pos = position, let size = frameSize else { return nil }
        return CGRect(origin: pos, size: size)
    }

    /// 부모 요소
    public var parent: AXElement? {
        attributeOrNil(AXAttribute.parent, as: AXElement.self)
    }

    /// 자식 요소들
    public var children: [AXElement] {
        attributeOrNil(AXAttribute.children, as: [AXElement].self) ?? []
    }

    /// 요소가 속한 프로세스 ID
    public var pid: pid_t? {
        var processID: pid_t = 0
        let error = AXUIElementGetPid(ref, &processID)
        guard error == .success else { return nil }
        return processID
    }

    // MARK: - 액션 수행

    /// 액션 수행
    public func performAction(_ action: String) throws {
        let error = AXUIElementPerformAction(ref, action as CFString)
        try AXKitError.check(error)
    }

    /// Press 액션 (클릭)
    public func press() throws {
        try performAction(AXAction.press)
    }

    /// Increment 액션
    public func increment() throws {
        try performAction(AXAction.increment)
    }

    /// Decrement 액션
    public func decrement() throws {
        try performAction(AXAction.decrement)
    }

    /// Confirm 액션
    public func confirm() throws {
        try performAction(AXAction.confirm)
    }

    /// Cancel 액션
    public func cancel() throws {
        try performAction(AXAction.cancel)
    }

    /// ShowMenu 액션
    public func showMenu() throws {
        try performAction(AXAction.showMenu)
    }

    /// 포커스 설정
    public func focus() throws {
        try setAttribute(AXAttribute.focused, value: kCFBooleanTrue)
    }

    /// 텍스트 값 설정
    public func setValue(_ text: String) throws {
        try setAttribute(AXAttribute.value, value: text as CFString)
    }

    /// 지원하는 액션 이름 목록
    public func actionNames() throws -> [String] {
        var names: CFArray?
        let error = AXUIElementCopyActionNames(ref, &names)
        try AXKitError.check(error)
        return (names as? [String]) ?? []
    }

    // MARK: - 트리 탐색

    /// 조건에 맞는 첫 번째 요소 찾기 (DFS)
    /// - Parameters:
    ///   - maxDepth: 최대 탐색 깊이 (기본값: 10)
    ///   - predicate: 조건 클로저
    /// - Returns: 조건에 맞는 첫 번째 요소
    /// - Throws: `AXKitError.elementNotFound` 요소를 찾을 수 없는 경우
    public func findFirst(
        maxDepth: Int = 10,
        where predicate: @Sendable (AXElement) -> Bool,
    ) throws -> AXElement {
        if predicate(self) { return self }

        guard maxDepth > 0 else {
            throw AXKitError.elementNotFound(description: "최대 깊이 도달")
        }

        for child in children {
            if let found = try? child.findFirst(maxDepth: maxDepth - 1, where: predicate) {
                return found
            }
        }

        throw AXKitError.elementNotFound(description: "조건에 맞는 요소 없음")
    }

    /// 조건에 맞는 모든 요소 찾기 (DFS)
    /// - Parameters:
    ///   - maxDepth: 최대 탐색 깊이 (기본값: 10)
    ///   - predicate: 조건 클로저
    /// - Returns: 조건에 맞는 모든 요소
    public func findAll(
        maxDepth: Int = 10,
        where predicate: @Sendable (AXElement) -> Bool,
    ) -> [AXElement] {
        var results: [AXElement] = []

        if predicate(self) {
            results.append(self)
        }

        guard maxDepth > 0 else { return results }

        for child in children {
            results.append(contentsOf: child.findAll(maxDepth: maxDepth - 1, where: predicate))
        }

        return results
    }

    /// 역할로 첫 번째 요소 찾기
    public func findFirst(role: String, maxDepth: Int = 10) throws -> AXElement {
        try findFirst(maxDepth: maxDepth) { $0.role == role }
    }

    /// 역할과 식별자로 첫 번째 요소 찾기
    public func findFirst(
        role: String,
        identifier: String,
        maxDepth: Int = 10,
    ) throws -> AXElement {
        try findFirst(maxDepth: maxDepth) { $0.role == role && $0.identifier == identifier }
    }

    /// 역할과 제목으로 첫 번째 요소 찾기
    public func findFirst(role: String, title: String, maxDepth: Int = 10) throws -> AXElement {
        try findFirst(maxDepth: maxDepth) { $0.role == role && $0.title == title }
    }

    /// 역할로 모든 요소 찾기
    public func findAll(role: String, maxDepth: Int = 10) -> [AXElement] {
        findAll(maxDepth: maxDepth) { $0.role == role }
    }

    /// 제목으로 버튼 찾기
    public func findButton(title: String, maxDepth: Int = 10) throws -> AXElement {
        try findFirst(role: AXRole.button, title: title, maxDepth: maxDepth)
    }

    /// 텍스트 필드 찾기
    /// - Parameters:
    ///   - identifier: 식별자 (nil이면 첫 번째 텍스트 필드)
    ///   - maxDepth: 최대 탐색 깊이
    public func findTextField(identifier: String? = nil, maxDepth: Int = 10) throws -> AXElement {
        if let id = identifier {
            return try findFirst(role: AXRole.textField, identifier: id, maxDepth: maxDepth)
        }
        return try findFirst(role: AXRole.textField, maxDepth: maxDepth)
    }
}

// MARK: - Equatable

extension AXElement: Equatable {
    public static func == (lhs: AXElement, rhs: AXElement) -> Bool {
        CFEqual(lhs.ref, rhs.ref)
    }
}

// MARK: - Hashable

extension AXElement: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(CFHash(ref))
    }
}

// MARK: - CustomStringConvertible

extension AXElement: CustomStringConvertible {
    public var description: String {
        var parts = ["AXElement("]

        if let role {
            parts.append(role)
        }

        if let title {
            parts.append(" \"\(title)\"")
        }

        if let identifier {
            parts.append(" #\(identifier)")
        }

        parts.append(")")
        return parts.joined()
    }
}
