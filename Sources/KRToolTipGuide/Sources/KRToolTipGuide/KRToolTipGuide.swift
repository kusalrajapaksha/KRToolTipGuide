// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// Main public interface for the TooltipGuide package
public struct TooltipGuide {
    
    /// Starts a tooltip guide with the provided steps
    /// - Parameter steps: Array of tooltip steps to display
    @MainActor
    public static func startGuide(_ steps: [TooltipData], configuration: TooltipOverlayConfiguration = .default) {
        TooltipManager.shared.startGuide(steps, configuration: configuration)
    }
    
    /// Ends the current tooltip guide
    @MainActor
    public static func endGuide() {
        TooltipManager.shared.endGuide()
    }
    
    /// Initializes tooltip tags for tracking
    /// - Parameter tags: Array of tag strings to track
    @MainActor
    public static func initializeTags(_ tags: [String]) {
        TooltipManager.shared.initializeTags(tags)
    }
    
    /// Sets up scroll proxy for automatic scrolling during guides
    /// - Parameter proxy: ScrollViewReader proxy
    @MainActor
    public static func setScrollProxy(_ proxy: ScrollViewProxy) {
        TooltipManager.shared.setScrollProxy(proxy)
    }
}

/// Convenience view modifier for setting up tooltip guides in a view hierarchy
public struct TooltipGuideSetup: ViewModifier {
    let tags: [String]
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                Task { @MainActor in
                    TooltipGuide.initializeTags(tags)
                }
            }
    }
}

public extension View {
    /// Sets up tooltip guide with the specified tags
    /// - Parameter tags: Array of tag strings to initialize
    /// - Returns: Modified view with tooltip guide setup
    func setupTooltipGuide(tags: [String]) -> some View {
        modifier(TooltipGuideSetup(tags: tags))
    }
}
