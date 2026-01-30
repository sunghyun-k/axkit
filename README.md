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

### Permission

```swift
import AXKit

// Check permission
if AXPermission.isGranted {
    print("Accessibility permission granted")
}

// Request permission with system dialog
AXPermission.request(prompt: true)
```

### Getting Elements

```swift
// Get application by bundle identifier
let safari = try AXElement.application(bundleIdentifier: "com.apple.Safari")

// Get application by PID
let app = AXElement.application(pid: processIdentifier)

// Get element at screen position
let element = try AXElement.element(at: CGPoint(x: 100, y: 200))
```

### Reading Attributes

```swift
// Convenience properties
let role = element.role           // String?
let title = element.title         // String?
let isEnabled = element.isEnabled // Bool
let children = element.children   // [AXElement]

// Batch attribute access (2x faster)
let (role, id, title) = element.attributes(.role, .identifier, .title)
```

### Performing Actions

```swift
try button.press()        // Click
try textField.focus()     // Focus
try textField.setValue("Hello")  // Set text
```

### Tree Traversal

```swift
// Find first button
let button = try window.findFirst(role: AXRole.button, maxDepth: 5)

// Find all text fields
let textFields = window.findAll(role: AXRole.textField, maxDepth: 10)

// Find with predicate
let element = try window.findFirst(maxDepth: 5) { $0.identifier == "submitBtn" }
```

## License

MIT
