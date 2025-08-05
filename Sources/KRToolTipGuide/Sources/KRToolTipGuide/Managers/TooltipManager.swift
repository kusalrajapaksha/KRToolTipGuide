//
//  TooltipManager.swift
//  KRToolTipGuide
//
//  Created by Kusal on 2025-08-05.
//
import SwiftUI
import Combine

/// Main manager class for handling tooltip guides
@MainActor
public class TooltipManager: ObservableObject {
    public static let shared = TooltipManager()

    @Published private(set) var tooltips: [TooltipData] = []
    @Published private(set) var currentIndex: Int = 0
    @Published var currentTooltip: TooltipData? = nil
    
    private var pendingFrames: [String: CGRect] = [:]
    private var scrollProxy: ScrollViewProxy?

    private init() {}

    /// Initializes tooltip tags for frame tracking
    /// - Parameter tags: Array of tag strings to track
    public func initializeTags(_ tags: [String]) {
        tooltips = tags.map { TooltipData(viewTag: $0, message: "") }
        
        // Apply any pending frames
        for (tag, rect) in pendingFrames {
            updateFrame(for: tag, rect: rect)
        }
    }
    
    /// Sets the scroll proxy for automatic scrolling
    /// - Parameter proxy: ScrollViewReader proxy
    public func setScrollProxy(_ proxy: ScrollViewProxy) {
        self.scrollProxy = proxy
    }

    /// Starts a tooltip guide with the provided steps
    /// - Parameter steps: Array of tooltip data for the guide
    public func startGuide(_ steps: [TooltipData], configuration: TooltipOverlayConfiguration) {
        // Merge new steps with existing frames
        var newTooltips = steps
        for i in 0..<newTooltips.count {
            if let existing = tooltips.first(where: { $0.viewTag == newTooltips[i].viewTag }) {
                newTooltips[i].rect = existing.rect
            }
            if let pendingRect = pendingFrames[newTooltips[i].viewTag] {
                newTooltips[i].rect = pendingRect
            }
        }
        tooltips = newTooltips
        pendingFrames.removeAll()
        currentIndex = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateCurrent(configuration: configuration)
            if self.currentTooltip != nil && !self.currentTooltip!.rect.isEmpty {
                TooltipWindowManager.shared.show {
                    TooltipOverlay(configuration: configuration).environmentObject(self)
                }
            } else {
                self.next()
            }
        }
    }

    /// Updates the frame for a specific tooltip tag
    /// - Parameters:
    ///   - tag: The tooltip tag
    ///   - rect: The frame rectangle
    public func updateFrame(for tag: String, rect: CGRect) {
        if let index = tooltips.firstIndex(where: { $0.viewTag == tag }) {
            tooltips[index].rect = rect
            if currentTooltip?.viewTag == tag {
                updateCurrent()
            }
        } else {
            pendingFrames[tag] = rect
        }
    }

    /// Advances to the next tooltip in the guide
    public func next() {
        guard currentIndex + 1 < tooltips.count else {
            endGuide()
            return
        }
        currentIndex += 1
        updateCurrent()
    }

    /// Ends the current tooltip guide
    public func endGuide() {
        TooltipWindowManager.shared.hide()
        currentTooltip = nil
        currentIndex = 0
        pendingFrames.removeAll()
    }

    private func updateCurrent(configuration: TooltipOverlayConfiguration = .default) {
        guard currentIndex < tooltips.count else {
            currentTooltip = nil
            endGuide()
            return
        }

        let tooltip = tooltips[currentIndex]

        if let id = tooltip.scrollID, let proxy = scrollProxy {
            proxy.scrollTo(id, anchor: .center)
            waitUntilFrameAvailable(for: tooltip.viewTag) { @MainActor in
                self.displayTooltip(tooltip, configuration: configuration)
            }
        } else {
            displayTooltip(tooltip, configuration: configuration)
        }
    }
    
    public func displayTooltip(_ tooltip: TooltipData, configuration: TooltipOverlayConfiguration = .default) {
        currentTooltip = tooltip

        if tooltip.rect.isEmpty {
            next()
        } else {
            TooltipWindowManager.shared.show {
                TooltipOverlay(configuration: configuration).environmentObject(self)
            }
        }
    }
    
    /// Waits for a frame to become available for a specific tag
    /// - Parameters:
    ///   - tag: The tooltip tag to wait for
    ///   - maxRetries: Maximum number of retry attempts
    ///   - delay: Delay between retry attempts
    ///   - completion: Completion handler called when frame is available or max retries reached
    public func waitUntilFrameAvailable(
        for tag: String,
        maxRetries: Int = 10,
        delay: TimeInterval = 0.1,
        completion: @escaping @MainActor @Sendable () -> Void
    ) {
        var retries = 0
        
        @MainActor
        func check() {
            if let tooltip = tooltips.first(where: { $0.viewTag == tag }), !tooltip.rect.isEmpty {
                completion()
            } else if retries < maxRetries {
                retries += 1
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    check()
                }
            } else {
                completion()
            }
        }
        check()
    }
    
    /// Async version of waitUntilFrameAvailable
    /// - Parameters:
    ///   - tag: The tooltip tag to wait for
    ///   - maxRetries: Maximum number of retry attempts
    ///   - delay: Delay between retry attempts
    /// - Returns: True if frame became available, false if max retries reached
    public func waitUntilFrameAvailable(
        for tag: String,
        maxRetries: Int = 10,
        delay: TimeInterval = 0.1
    ) async -> Bool {
        var retries = 0
        
        while retries < maxRetries {
            if let tooltip = tooltips.first(where: { $0.viewTag == tag }), !tooltip.rect.isEmpty {
                return true
            }
            
            retries += 1
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        return false
    }
}
