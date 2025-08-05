//
//  TooltipFramePreferenceKey.swift
//  KRToolTipGuide
//
//  Created by Kusal on 2025-08-05.
//

import SwiftUI

/// Preference key to capture view frames for tooltips
public struct TooltipFramePreferenceKey: PreferenceKey {
    public static let defaultValue: [String: CGRect] = [:]
    
    public static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// View extension for capturing tooltip frames
public extension View {
    /// Captures the frame of a view for tooltip positioning
    /// - Parameter tag: The tooltip tag to associate with this view
    /// - Returns: Modified view with frame capture capability
    func captureTooltipFrame<T: TooltipTagProtocol>(tag: T) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: TooltipFramePreferenceKey.self, value: [tag.rawValue: geo.frame(in: .global)])
            }
        )
        .onPreferenceChange(TooltipFramePreferenceKey.self) { frames in
            if let rect = frames[tag.rawValue] {
                TooltipManager.shared.updateFrame(for: tag.rawValue, rect: rect)
            }
        }
    }
    
    /// Captures the frame using a string tag
    /// - Parameter tag: String identifier for the tooltip
    /// - Returns: Modified view with frame capture capability
    func captureTooltipFrame(tag: String) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: TooltipFramePreferenceKey.self, value: [tag: geo.frame(in: .global)])
            }
        )
        .onPreferenceChange(TooltipFramePreferenceKey.self) { frames in
            if let rect = frames[tag] {
                TooltipManager.shared.updateFrame(for: tag, rect: rect)
            }
        }
    }
}
