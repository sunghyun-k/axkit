# AXKit

A Swift wrapper for macOS Accessibility API (ApplicationServices). Transforms the low-level C-based `AXUIElement` API into a type-safe Swift interface.

## Requirements

- macOS 13.0+
- Swift 6.1+

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunghyun-k/axkit", from: "0.1.0")
]
```

## Usage

```swift
import AXKit

// Check accessibility permission
guard checkAccessibilityPermission() else { return }

// Get application by bundle ID
if let app = AXElement.application(bundleId: "com.apple.Safari") {
    print(app.title)

    // Get windows
    for window in app.windows {
        print(window.frame)
    }

    // Find element by identifier
    if let button = app.find(identifier: "myButton") {
        button.press()
    }
}

// Get element at screen position
if let element = AXElement.elementAtPosition(CGPoint(x: 100, y: 100)) {
    print(element.role)
}
```

## Features

- **Element Creation**: System-wide, by PID, by bundle ID, or at screen position
- **Attribute Access**: Generic and typed accessors for strings, bools, numbers, points, sizes, rects
- **Attribute Modification**: Set element attributes with type-safe methods
- **Actions**: Perform accessibility actions (press, cancel, etc.)
- **Tree Traversal**: Navigate parent/children, find elements by predicate or identifier

## License

MIT
