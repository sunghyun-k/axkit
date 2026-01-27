import AppKit
@preconcurrency import ApplicationServices

/// AXUIElement의 Swift 래퍼
public final class AXElement: @unchecked Sendable {
    public let ref: AXUIElement

    public init(_ ref: AXUIElement) {
        self.ref = ref
    }

    // MARK: - Constructors

    /// 시스템 전체 요소 (마우스 위치의 요소 찾기 등에 사용)
    public static var systemWide: AXElement {
        AXElement(AXUIElementCreateSystemWide())
    }

    /// PID로 애플리케이션 요소 생성
    public static func application(pid: pid_t) -> AXElement? {
        let ref = AXUIElementCreateApplication(pid)
        // 유효한 애플리케이션인지 확인
        guard let role: String = AXElement(ref).attribute(kAXRoleAttribute),
              role == kAXApplicationRole as String
        else {
            return nil
        }
        return AXElement(ref)
    }

    /// Bundle ID로 애플리케이션 요소 생성
    public static func application(bundleId: String) -> AXElement? {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first else {
            return nil
        }
        return application(pid: app.processIdentifier)
    }

    /// 화면 좌표에서 요소 찾기
    public static func elementAtPosition(_ point: CGPoint) -> AXElement? {
        var element: AXUIElement?
        let error = AXUIElementCopyElementAtPosition(systemWide.ref, Float(point.x), Float(point.y), &element)
        guard error == .success, let element else { return nil }
        return AXElement(element)
    }

    // MARK: - Attribute Names

    /// 지원하는 모든 속성 이름 목록
    public var attributeNames: [String] {
        var names: CFArray?
        guard AXUIElementCopyAttributeNames(ref, &names) == .success,
              let names = names as? [String] else { return [] }
        return names
    }

    /// 지원하는 모든 액션 이름 목록
    public var actionNames: [String] {
        var names: CFArray?
        guard AXUIElementCopyActionNames(ref, &names) == .success,
              let names = names as? [String] else { return [] }
        return names
    }

    // MARK: - Attribute Read

    /// 속성 값 가져오기 (제네릭)
    public func attribute<T>(_ name: CFString) -> T? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(ref, name, &value) == .success else { return nil }
        return value as? T
    }

    /// 속성 값 가져오기 (String 키)
    public func attribute<T>(_ name: String) -> T? {
        attribute(name as CFString)
    }

    /// 문자열 속성
    public func stringAttribute(_ name: String) -> String? {
        attribute(name)
    }

    /// Bool 속성
    public func boolAttribute(_ name: String) -> Bool? {
        guard let value: CFBoolean = attribute(name) else { return nil }
        return CFBooleanGetValue(value)
    }

    /// 숫자 속성
    public func numberAttribute(_ name: String) -> Int? {
        guard let value: CFNumber = attribute(name) else { return nil }
        var result = 0
        CFNumberGetValue(value, .sInt64Type, &result)
        return result
    }

    /// AXElement 속성
    public func elementAttribute(_ name: String) -> AXElement? {
        guard let value: AXUIElement = attribute(name) else { return nil }
        return AXElement(value)
    }

    /// AXElement 배열 속성
    public func elementsAttribute(_ name: String) -> [AXElement] {
        guard let values: [AXUIElement] = attribute(name) else { return [] }
        return values.map { AXElement($0) }
    }

    /// CGPoint 속성 (AXValue에서 추출)
    public func pointAttribute(_ name: String) -> CGPoint? {
        guard let value: AXValue = attribute(name) else { return nil }
        var point = CGPoint.zero
        guard AXValueGetValue(value, .cgPoint, &point) else { return nil }
        return point
    }

    /// CGSize 속성 (AXValue에서 추출)
    public func sizeAttribute(_ name: String) -> CGSize? {
        guard let value: AXValue = attribute(name) else { return nil }
        var size = CGSize.zero
        guard AXValueGetValue(value, .cgSize, &size) else { return nil }
        return size
    }

    /// CGRect 속성 (AXValue에서 추출)
    public func rectAttribute(_ name: String) -> CGRect? {
        guard let value: AXValue = attribute(name) else { return nil }
        var rect = CGRect.zero
        guard AXValueGetValue(value, .cgRect, &rect) else { return nil }
        return rect
    }

    /// CFRange 속성 (AXValue에서 추출)
    public func rangeAttribute(_ name: String) -> CFRange? {
        guard let value: AXValue = attribute(name) else { return nil }
        var range = CFRange(location: 0, length: 0)
        guard AXValueGetValue(value, .cfRange, &range) else { return nil }
        return range
    }

    // MARK: - Attribute Write

    /// 속성 값 설정
    @discardableResult
    public func setAttribute(_ name: String, value: CFTypeRef) -> AXError {
        AXUIElementSetAttributeValue(ref, name as CFString, value)
    }

    /// 문자열 속성 설정
    @discardableResult
    public func setStringAttribute(_ name: String, value: String) -> AXError {
        setAttribute(name, value: value as CFString)
    }

    /// Bool 속성 설정
    @discardableResult
    public func setBoolAttribute(_ name: String, value: Bool) -> AXError {
        setAttribute(name, value: value ? kCFBooleanTrue : kCFBooleanFalse)
    }

    /// CGPoint 속성 설정
    @discardableResult
    public func setPointAttribute(_ name: String, value: CGPoint) -> AXError {
        var point = value
        guard let axValue = AXValueCreate(.cgPoint, &point) else { return .failure }
        return setAttribute(name, value: axValue)
    }

    /// CGSize 속성 설정
    @discardableResult
    public func setSizeAttribute(_ name: String, value: CGSize) -> AXError {
        var size = value
        guard let axValue = AXValueCreate(.cgSize, &size) else { return .failure }
        return setAttribute(name, value: axValue)
    }

    // MARK: - Actions

    /// 액션 수행
    @discardableResult
    public func performAction(_ action: String) -> AXError {
        AXUIElementPerformAction(ref, action as CFString)
    }

    /// Press 액션 (클릭)
    @discardableResult
    public func press() -> AXError {
        performAction(kAXPressAction as String)
    }

    /// Cancel 액션
    @discardableResult
    public func cancel() -> AXError {
        performAction(kAXCancelAction as String)
    }

    // MARK: - Common Attributes (편의 프로퍼티)

    public var role: String? { stringAttribute(kAXRoleAttribute as String) }
    public var subrole: String? { stringAttribute(kAXSubroleAttribute as String) }
    public var title: String? { stringAttribute(kAXTitleAttribute as String) }
    public var value: String? { stringAttribute(kAXValueAttribute as String) }
    public var valueDescription: String? { stringAttribute(kAXValueDescriptionAttribute as String) }
    public var axDescription: String? { stringAttribute(kAXDescriptionAttribute as String) }
    public var identifier: String? { stringAttribute(kAXIdentifierAttribute as String) }
    public var help: String? { stringAttribute(kAXHelpAttribute as String) }

    public var isEnabled: Bool { boolAttribute(kAXEnabledAttribute as String) ?? false }
    public var isFocused: Bool { boolAttribute(kAXFocusedAttribute as String) ?? false }
    public var isSelected: Bool { boolAttribute(kAXSelectedAttribute as String) ?? false }

    public var position: CGPoint? { pointAttribute(kAXPositionAttribute as String) }
    public var size: CGSize? { sizeAttribute(kAXSizeAttribute as String) }
    public var frame: CGRect? {
        guard let pos = position, let sz = size else { return nil }
        return CGRect(origin: pos, size: sz)
    }

    public var children: [AXElement] { elementsAttribute(kAXChildrenAttribute as String) }
    public var parent: AXElement? { elementAttribute(kAXParentAttribute as String) }
    public var windows: [AXElement] { elementsAttribute(kAXWindowsAttribute as String) }
    public var focusedWindow: AXElement? { elementAttribute(kAXFocusedWindowAttribute as String) }
    public var mainWindow: AXElement? { elementAttribute(kAXMainWindowAttribute as String) }
    public var focusedUIElement: AXElement? { elementAttribute(kAXFocusedUIElementAttribute as String) }

    // MARK: - Process Info

    /// 요소의 PID 가져오기
    public var pid: pid_t? {
        var pid: pid_t = 0
        guard AXUIElementGetPid(ref, &pid) == .success else { return nil }
        return pid
    }

    // MARK: - Search

    /// 역할로 자식 필터링
    public func children(withRole role: String) -> [AXElement] {
        children.filter { $0.role == role }
    }

    /// 조건으로 하위 요소 찾기 (재귀, DFS)
    public func findFirst(where predicate: (AXElement) -> Bool, maxDepth: Int = 10) -> AXElement? {
        findFirstImpl(predicate: predicate, maxDepth: maxDepth, currentDepth: 0)
    }

    private func findFirstImpl(predicate: (AXElement) -> Bool, maxDepth: Int, currentDepth: Int) -> AXElement? {
        guard currentDepth < maxDepth else { return nil }
        for child in children {
            if predicate(child) { return child }
            if let found = child.findFirstImpl(predicate: predicate, maxDepth: maxDepth, currentDepth: currentDepth + 1) {
                return found
            }
        }
        return nil
    }

    /// ID로 하위 요소 찾기
    public func find(identifier: String, maxDepth: Int = 10) -> AXElement? {
        findFirst(where: { $0.identifier == identifier }, maxDepth: maxDepth)
    }

    /// 조건으로 모든 하위 요소 찾기 (재귀)
    public func findAll(where predicate: (AXElement) -> Bool, maxDepth: Int = 10) -> [AXElement] {
        var results: [AXElement] = []
        findAllImpl(predicate: predicate, results: &results, maxDepth: maxDepth, currentDepth: 0)
        return results
    }

    private func findAllImpl(predicate: (AXElement) -> Bool, results: inout [AXElement], maxDepth: Int, currentDepth: Int) {
        guard currentDepth < maxDepth else { return }
        for child in children {
            if predicate(child) { results.append(child) }
            child.findAllImpl(predicate: predicate, results: &results, maxDepth: maxDepth, currentDepth: currentDepth + 1)
        }
    }

    /// 역할로 모든 하위 요소 찾기
    public func findAll(withRole role: String, maxDepth: Int = 10) -> [AXElement] {
        findAll(where: { $0.role == role }, maxDepth: maxDepth)
    }
}

// MARK: - Accessibility Permission

/// 접근성 권한 확인 (프롬프트 표시 옵션)
public func checkAccessibilityPermission(prompt: Bool = true) -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): prompt] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
}

// MARK: - Running Applications Helper

public extension NSRunningApplication {
    /// AXElement로 변환
    var axElement: AXElement? {
        AXElement.application(pid: processIdentifier)
    }
}
