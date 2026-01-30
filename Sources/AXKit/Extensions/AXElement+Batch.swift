import ApplicationServices

extension AXElement {
    /// Parameter Pack을 사용한 배치 속성 조회
    ///
    /// 여러 속성을 한 번의 IPC 호출로 가져옵니다. 개별 접근 대비 약 2배 빠릅니다.
    ///
    /// ```swift
    /// let (role, id, title) = element.attributes(.role, .identifier, .title)
    /// // role: String?, id: String?, title: String?
    /// ```
    public func attributes<each T>(_ keys: repeat AttributeKey<each T>) -> (repeat (each T)?) {
        // 1. 키 이름들 수집
        var names: [String] = []
        for name in repeat (each keys).name {
            names.append(name)
        }

        // 빈 키면 빈 튜플 반환
        guard !names.isEmpty else {
            return (repeat nil as (each T)?)
        }

        // 2. 배치 호출
        var valuesRef: CFArray?
        let error = AXUIElementCopyMultipleAttributeValues(
            ref,
            names as CFArray,
            .stopOnError,
            &valuesRef,
        )

        guard error == .success, let values = valuesRef as? [Any] else {
            return (repeat nil as (each T)?)
        }

        // 3. 결과 매핑
        var index = 0
        func nextValue<V>(_: AttributeKey<V>) -> V? {
            defer { index += 1 }
            guard index < values.count else { return nil }
            let value = values[index]

            // kAXErrorNoValue 체크
            if value is NSNull { return nil }

            // AXUIElement -> AXElement 변환
            if V.self == AXElement.self {
                guard CFGetTypeID(value as CFTypeRef) == AXUIElementGetTypeID() else { return nil }
                return AXElement(value as! AXUIElement) as? V
            }

            // [AXUIElement] -> [AXElement] 변환
            if V.self == [AXElement].self {
                guard let array = value as? [AXUIElement] else { return nil }
                return array.map { AXElement($0) } as? V
            }

            // CGPoint 변환
            if V.self == CGPoint.self {
                guard CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() else { return nil }
                var point = CGPoint.zero
                guard AXValueGetValue(value as! AXValue, .cgPoint, &point) else { return nil }
                return point as? V
            }

            // CGSize 변환
            if V.self == CGSize.self {
                guard CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() else { return nil }
                var size = CGSize.zero
                guard AXValueGetValue(value as! AXValue, .cgSize, &size) else { return nil }
                return size as? V
            }

            return value as? V
        }

        return (repeat nextValue(each keys))
    }
}
