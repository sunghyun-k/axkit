import ApplicationServices

extension AXError: @retroactive Error, @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .success: return "Success"
        case .failure: return "A system error occurred"
        case .illegalArgument: return "Illegal argument"
        case .invalidUIElement: return "Invalid UI element"
        case .invalidUIElementObserver: return "Invalid observer"
        case .cannotComplete: return "Messaging failed"
        case .attributeUnsupported: return "Attribute unsupported"
        case .actionUnsupported: return "Action unsupported"
        case .notificationUnsupported: return "Notification unsupported"
        case .notImplemented: return "Not implemented"
        case .notificationAlreadyRegistered: return "Notification already registered"
        case .notificationNotRegistered: return "Notification not registered"
        case .apiDisabled: return "Accessibility API disabled"
        case .noValue: return "No value"
        case .parameterizedAttributeUnsupported: return "Parameterized attribute unsupported"
        case .notEnoughPrecision: return "Not enough precision"
        @unknown default: return "Unknown error (\(rawValue))"
        }
    }

    var isSuccess: Bool { self == .success }
}
