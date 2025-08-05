//
//  ConcurrencySafeUpdates.swift
//  KRToolTipGuide
//
//  Created by Kusal on 2025-08-05.
//
import SwiftUI

public extension TooltipManager {
    nonisolated func updateFrameSafely(for tag: String, rect: CGRect) {
        Task { @MainActor in
            self.updateFrame(for: tag, rect: rect)
        }
    }
    
    nonisolated func waitForFrameAsync(
        for tag: String,
        maxRetries: Int = 10,
        delay: TimeInterval = 0.1
    ) async -> Bool {
        await self.waitUntilFrameAvailable(for: tag, maxRetries: maxRetries, delay: delay)
    }
}

public extension TooltipWindowManager {
    nonisolated func showSafely<Overlay: View>(@ViewBuilder overlay: @escaping @Sendable () -> Overlay) {
        Task { @MainActor in
            self.show(overlay: overlay)
        }
    }
    
    nonisolated func hideSafely() {
        Task { @MainActor in
            self.hide()
        }
    }
}

public extension TooltipGuide {
    @MainActor
    static func startGuideSafely(_ steps: [TooltipData], configuration: TooltipOverlayConfiguration = .default) {
        TooltipManager.shared.startGuide(steps, configuration: configuration)
    }
    
    static func endGuideSafely() {
        Task { @MainActor in
            TooltipManager.shared.endGuide()
        }
    }
    
    static func initializeTagsSafely(_ tags: [String]) {
        Task { @MainActor in
            TooltipManager.shared.initializeTags(tags)
        }
    }
}

public struct SendableTooltipActions {
    @MainActor
    public static func displayAction(for manager: TooltipManager, tooltip: TooltipData) -> () -> Void {
        return {
            Task { @MainActor in
                manager.displayTooltip(tooltip)
            }
        }
    }
    
    @MainActor
    public static func endGuideAction(for manager: TooltipManager) -> () -> Void {
        return {
            Task { @MainActor in
                manager.endGuide()
            }
        }
    }
}
