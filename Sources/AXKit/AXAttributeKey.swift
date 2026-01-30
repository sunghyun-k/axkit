import ApplicationServices

/// 타입 안전한 속성 키
public struct AttributeKey<Value>: Sendable {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }
}

// MARK: - String 속성

extension AttributeKey where Value == String {
    public static var role: Self { .init(kAXRoleAttribute as String) }
    public static var subrole: Self { .init(kAXSubroleAttribute as String) }
    public static var roleDescription: Self { .init(kAXRoleDescriptionAttribute as String) }
    public static var identifier: Self { .init(kAXIdentifierAttribute as String) }
    public static var title: Self { .init(kAXTitleAttribute as String) }
    public static var axDescription: Self { .init(kAXDescriptionAttribute as String) }
    public static var help: Self { .init(kAXHelpAttribute as String) }
    public static var stringValue: Self { .init(kAXValueAttribute as String) }
    public static var selectedText: Self { .init(kAXSelectedTextAttribute as String) }
}

// MARK: - Bool 속성

extension AttributeKey where Value == Bool {
    public static var enabled: Self { .init(kAXEnabledAttribute as String) }
    public static var focused: Self { .init(kAXFocusedAttribute as String) }
    public static var selected: Self { .init(kAXSelectedAttribute as String) }
    public static var frontmost: Self { .init(kAXFrontmostAttribute as String) }
    public static var hidden: Self { .init(kAXHiddenAttribute as String) }
}

// MARK: - Int 속성

extension AttributeKey where Value == Int {
    public static var numberOfCharacters: Self { .init(kAXNumberOfCharactersAttribute as String) }
    public static var insertionPointLineNumber: Self {
        .init(kAXInsertionPointLineNumberAttribute as String)
    }
}

// MARK: - Any 속성

extension AttributeKey where Value == Any {
    public static var value: Self { .init(kAXValueAttribute as String) }
}

// MARK: - AXElement 속성

extension AttributeKey where Value == AXElement {
    public static var parent: Self { .init(kAXParentAttribute as String) }
    public static var topLevelUIElement: Self { .init(kAXTopLevelUIElementAttribute as String) }
    public static var mainWindow: Self { .init(kAXMainWindowAttribute as String) }
    public static var focusedWindow: Self { .init(kAXFocusedWindowAttribute as String) }
    public static var focusedUIElement: Self { .init(kAXFocusedUIElementAttribute as String) }
    public static var menuBar: Self { .init(kAXMenuBarAttribute as String) }
}

// MARK: - [AXElement] 속성

extension AttributeKey where Value == [AXElement] {
    public static var children: Self { .init(kAXChildrenAttribute as String) }
    public static var windows: Self { .init(kAXWindowsAttribute as String) }
}

// MARK: - CGPoint 속성

extension AttributeKey where Value == CGPoint {
    public static var position: Self { .init(kAXPositionAttribute as String) }
}

// MARK: - CGSize 속성

extension AttributeKey where Value == CGSize {
    public static var size: Self { .init(kAXSizeAttribute as String) }
}
