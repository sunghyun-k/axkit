import ApplicationServices

/// AXKit 에러 타입
public enum AXKitError: Error, Sendable {
    // MARK: - Accessibility API 에러

    /// 접근성 API가 비활성화됨 (시스템 설정에서 활성화 필요)
    case accessibilityDisabled

    /// 해당 액션이 지원되지 않음
    case actionUnsupported

    /// 해당 속성이 지원되지 않음
    case attributeUnsupported

    /// API가 현재 사용 불가
    case apiDisabled

    /// 잘못된 UI 요소
    case invalidUIElement

    /// 잘못된 UI 요소 옵저버
    case invalidUIElementObserver

    /// 요소에 해당 파라미터화된 속성이 없음
    case noParameterizedAttribute

    /// 알 수 없는 Accessibility API 에러
    case unknownAPIError(AXError)

    /// 요소를 찾을 수 없음
    case cannotComplete

    /// 알림 지원되지 않음
    case notificationUnsupported

    /// 알림이 이미 등록됨
    case notificationAlreadyRegistered

    /// 해당 속성에 쓰기 불가
    case notSettable

    // MARK: - AXKit 자체 에러

    /// 타입 불일치 (기대한 타입과 실제 타입이 다름)
    case typeMismatch(expected: String, actual: String)

    /// 요소를 찾을 수 없음
    case elementNotFound(description: String)

    /// 애플리케이션을 찾을 수 없음
    case applicationNotFound(bundleIdentifier: String)

    /// 속성 값이 nil
    case attributeNil(attribute: String)

    /// 권한이 없음
    case permissionDenied

    // MARK: - AXError 변환

    /// AXError를 AXKitError로 변환
    public static func from(_ axError: AXError) -> AXKitError {
        switch axError {
        case .success:
            fatalError("success는 에러가 아닙니다")
        case .failure:
            return .cannotComplete
        case .illegalArgument:
            return .invalidUIElement
        case .invalidUIElement:
            return .invalidUIElement
        case .invalidUIElementObserver:
            return .invalidUIElementObserver
        case .cannotComplete:
            return .cannotComplete
        case .attributeUnsupported:
            return .attributeUnsupported
        case .actionUnsupported:
            return .actionUnsupported
        case .notificationUnsupported:
            return .notificationUnsupported
        case .notImplemented:
            return .apiDisabled
        case .notificationAlreadyRegistered:
            return .notificationAlreadyRegistered
        case .notificationNotRegistered:
            return .unknownAPIError(axError)
        case .apiDisabled:
            return .accessibilityDisabled
        case .noValue:
            return .attributeNil(attribute: "unknown")
        case .parameterizedAttributeUnsupported:
            return .noParameterizedAttribute
        case .notEnoughPrecision:
            return .unknownAPIError(axError)
        @unknown default:
            return .unknownAPIError(axError)
        }
    }

    /// AXError를 검사하고 실패 시 throw
    public static func check(_ error: AXError, attribute: String? = nil) throws {
        guard error != .success else { return }

        if error == .noValue, let attr = attribute {
            throw AXKitError.attributeNil(attribute: attr)
        }

        throw AXKitError.from(error)
    }
}

// MARK: - LocalizedError

extension AXKitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .accessibilityDisabled:
            "접근성 API가 비활성화되어 있습니다. 시스템 설정 > 개인정보 보호 및 보안 > 접근성에서 앱을 허용해주세요."
        case .actionUnsupported:
            "해당 액션이 이 요소에서 지원되지 않습니다."
        case .attributeUnsupported:
            "해당 속성이 이 요소에서 지원되지 않습니다."
        case .apiDisabled:
            "접근성 API를 사용할 수 없습니다."
        case .invalidUIElement:
            "유효하지 않은 UI 요소입니다. 요소가 이미 제거되었을 수 있습니다."
        case .invalidUIElementObserver:
            "유효하지 않은 UI 요소 옵저버입니다."
        case .noParameterizedAttribute:
            "파라미터화된 속성이 지원되지 않습니다."
        case .unknownAPIError(let axError):
            "알 수 없는 접근성 API 에러가 발생했습니다: \(axError)"
        case .cannotComplete:
            "작업을 완료할 수 없습니다. 요소가 존재하지 않거나 접근할 수 없습니다."
        case .notificationUnsupported:
            "해당 알림이 지원되지 않습니다."
        case .notificationAlreadyRegistered:
            "해당 알림이 이미 등록되어 있습니다."
        case .notSettable:
            "해당 속성은 읽기 전용입니다."
        case .typeMismatch(let expected, let actual):
            "타입 불일치: '\(expected)' 타입을 기대했지만 '\(actual)' 타입을 받았습니다."
        case .elementNotFound(let description):
            "요소를 찾을 수 없습니다: \(description)"
        case .applicationNotFound(let bundleId):
            "애플리케이션을 찾을 수 없습니다: \(bundleId)"
        case .attributeNil(let attribute):
            "속성 '\(attribute)'의 값이 없습니다."
        case .permissionDenied:
            "접근성 권한이 거부되었습니다."
        }
    }
}
