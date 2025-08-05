# TooltipGuide

A SwiftUI package for creating interactive tooltip guides and onboarding experiences in iOS apps.

## Features

- 🎯 **Easy Integration**: Simple API for adding tooltips to any SwiftUI view
- 🔄 **Automatic Scrolling**: Smart scrolling to ensure tooltips are visible
- 🎨 **Customizable**: Configurable appearance and behavior
- 📱 **Responsive**: Automatic positioning that adapts to screen constraints
- 🪟 **Overlay System**: Uses separate windows for seamless overlay experience

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/kusalrajapaksha/KRToolTipGuide.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Choose your version requirements

## Usage

### Basic Setup

```swift
import SwiftUI
import TooltipGuide

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome")
                .captureTooltipFrame(tag: "welcome")
            
            Button("Get Started") {
                // Button action
            }
            .captureTooltipFrame(tag: "button")
        }
        .setupTooltipGuide(tags: ["welcome", "button"])
        .onAppear {
            startTutorial()
        }
    }
    
    private func startTutorial() {
        let steps = [
            TooltipData(viewTag: "welcome", message: "Welcome to our app!"),
            TooltipData(viewTag: "button", message: "Tap here to get started")
        ]
        
        TooltipGuide.startGuide(steps)
    }
}
```

### Advanced Usage with ScrollView

```swift
struct ScrollableContent: View {
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(0..<50, id: \.self) { index in
                        Text("Item \(index)")
                            .id("item_\(index)")
                            .captureTooltipFrame(tag: "item_\(index)")
                    }
                }
            }
            .setupTooltipGuide(tags: (0..<50).map { "item_\($0)" })
            .onAppear {
                TooltipGuide.setScrollProxy(proxy)
                startScrollableGuide()
            }
        }
    }
    
    private func startScrollableGuide() {
        let steps = [
            TooltipData(viewTag: "item_10", message: "This is item 10", scrollID: "item_10"),
            TooltipData(viewTag: "item_25", message: "This is item 25", scrollID: "item_25"),
            TooltipData(viewTag: "item_40", message: "This is item 40", scrollID: "item_40")
        ]
        
        TooltipGuide.startGuide(steps)
    }
}
```

### Custom Appearance

```swift
let customConfig = TooltipOverlayConfiguration(
    dimOpacity: 0.8,
    cornerRadius: 15,
    backgroundColor: .blue,
    textColor: .white,
    skipButtonText: "Skip",
    nextButtonText: "Continue",
    doneButtonText: "Finish"
)

// Use custom configuration in your overlay
TooltipOverlay(configuration: customConfig)
```

## API Reference

### TooltipData

```swift
public struct TooltipData {
    public let viewTag: String      // Unique identifier for the target view
    public let message: String      // Tooltip message to display
    public var scrollID: String?    // Optional scroll target ID
}
```

### TooltipGuide

```swift
// Start a tooltip guide
TooltipGuide.startGuide([TooltipData])

// End the current guide
TooltipGuide.endGuide()

// Initialize tags for tracking
TooltipGuide.initializeTags([String])

// Set scroll proxy for automatic scrolling
TooltipGuide.setScrollProxy(ScrollViewProxy)
```

### View Extensions

```swift
// Capture frame for tooltip positioning
.captureTooltipFrame(tag: "myTag")

// Setup tooltip guide with tags
.setupTooltipGuide(tags: ["tag1", "tag2"])
```

### Custom Tag Types

You can create your own tooltip tag enums:

```swift
enum MyTooltipTags: String, TooltipTagProtocol {
    case header = "header"
    case sidebar = "sidebar"
    case footer = "footer"
}

// Use with views
Text("Header")
    .captureTooltipFrame(tag: MyTooltipTags.header)
```

## Requirements

- iOS 14.0+
- SwiftUI
- Xcode 12.0+

## License

This package is available under the MIT license. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
