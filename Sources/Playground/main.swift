import AppKit
import AXKit

print("=== Parameter Pack 배치 API 테스트 ===\n")

let runningApps = NSWorkspace.shared.runningApplications
guard let kakaoApp = runningApps.first(where: { $0.bundleIdentifier?.contains("kakao") == true })
else {
    fatalError("카카오톡 없음")
}

let app = AXElement.application(pid: kakaoApp.processIdentifier)
guard let mainWindow = app.windows.first(where: { $0.identifier == "Main Window" }) else {
    fatalError("메인 창 없음")
}

// 단일 요소 테스트
print("📍 단일 요소 테스트")
let (role, identifier, title) = mainWindow.attributes(.role, .identifier, .title)
print("  role: \(role ?? "nil")")
print("  identifier: \(identifier ?? "nil")")
print("  title: \(title ?? "nil")")

print()

// 성능 비교
let chatTab = mainWindow.children.first { $0.identifier == "chatrooms" }!
try? chatTab.press()
Thread.sleep(forTimeInterval: 0.3)

guard let scrollArea = mainWindow.children.first(where: { $0.role == AXRole.scrollArea }),
      let table = scrollArea.children.first(where: { $0.role == AXRole.table })
else {
    fatalError("테이블 없음")
}

// 테스트 요소 수집
var testElements: [AXElement] = []
let rows = table.children.filter { $0.role == AXRole.row }
for row in rows.prefix(30) {
    if let cell = row.children.first(where: { $0.role == AXRole.cell }) {
        testElements.append(contentsOf: cell.children)
    }
}

print("테스트 요소: \(testElements.count)개\n")

// 방법 1: 개별 호출
print("📊 방법 1: 개별 속성 접근")
var start = CFAbsoluteTimeGetCurrent()
for element in testElements {
    _ = element.role
    _ = element.identifier
}

var elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
print("  소요: \(String(format: "%.1f", elapsed))ms")

// 방법 2: Parameter Pack 배치
print("\n📊 방법 2: attributes() - Parameter Pack + 배치")
start = CFAbsoluteTimeGetCurrent()
for element in testElements {
    _ = element.attributes(.role, .identifier)
}

elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
print("  소요: \(String(format: "%.1f", elapsed))ms")

// 방법 3: 더 많은 속성 배치
print("\n📊 방법 3: 4개 속성 배치 (role, identifier, title, enabled)")
start = CFAbsoluteTimeGetCurrent()
for element in testElements {
    _ = element.attributes(.role, .identifier, .title, .enabled)
}

elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
print("  소요: \(String(format: "%.1f", elapsed))ms")

print("\n=== 완료 ===")
