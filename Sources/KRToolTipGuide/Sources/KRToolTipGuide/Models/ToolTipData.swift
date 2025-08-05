//
//  ToolTipData.swift
//  KRToolTipGuide
//
//  Created by Kusal on 2025-08-05.
//

import SwiftUI

/// Data model for tooltip information
public struct TooltipData: Identifiable, Sendable {
    public let id = UUID()
    public let viewTag: String
    public let message: String
    public var rect: CGRect = .zero
    public var scrollID: String? = nil
    
    public init(viewTag: String, message: String, scrollID: String? = nil) {
        self.viewTag = viewTag
        self.message = message
        self.scrollID = scrollID
    }
}

/// Anchor position for tooltip arrow
public enum TooltipAnchorPosition: Sendable {
    case top
    case bottom
}

/// Protocol for tooltip tag types - allows users to define their own enums
public protocol TooltipTagProtocol {
    var rawValue: String { get }
}

/// Default tooltip tag enum
public enum TooltipTag: String, TooltipTagProtocol, CaseIterable {
    case example1 = "example1"
    case example2 = "example2"
    case example3 = "example3"
}
