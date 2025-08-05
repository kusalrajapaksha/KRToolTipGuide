//
//  TooltipWindowManager.swift
//  KRToolTipGuide
//
//  Created by Kusal on 2025-08-05.
//

import UIKit
import SwiftUI

/// Manager for displaying tooltip overlay in a separate window
@MainActor
public final class TooltipWindowManager: ObservableObject {
    public static let shared = TooltipWindowManager()

    private var window: UIWindow?

    private init() {}

    /// Shows the tooltip overlay in a separate window
    /// - Parameter overlay: The overlay view to display
    public func show<Overlay: View>(@ViewBuilder overlay: @escaping () -> Overlay) {
        guard window == nil else {
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first else {
            return
        }

        let hosting = UIHostingController(rootView: overlay())
        hosting.view.backgroundColor = .clear

        let newWindow = UIWindow(windowScene: windowScene)
        newWindow.rootViewController = hosting
        newWindow.windowLevel = .alert + 1
        newWindow.makeKeyAndVisible()

        self.window = newWindow
    }

    /// Hides the tooltip overlay window
    public func hide() {
        window?.isHidden = true
        window = nil
    }
    
    /// Calculates the optimal position for a tooltip
    /// - Parameters:
    ///   - tooltip: The tooltip data containing target rect
    ///   - tooltipSize: The size of the tooltip view
    ///   - screenSize: The screen size
    ///   - safeAreaInsets: Safe area insets
    /// - Returns: A tuple containing the position and anchor direction
    public static func calculateTooltipPosition(
        tooltip: TooltipData,
        tooltipSize: CGSize,
        screenSize: CGSize,
        safeAreaInsets: EdgeInsets
    ) -> (CGPoint, TooltipAnchorPosition) {
        let padding: CGFloat = 16
        let tooltipWidth = max(tooltipSize.width, 50)
        let tooltipHeight = max(tooltipSize.height, 50)
        
        // Calculate X position
        var x = tooltip.rect.minX
        
        // Clamp X to ensure tooltip stays within screen bounds
        if x + tooltipWidth >= screenSize.width - padding {
            let subX = screenSize.width - tooltipWidth - padding
            x = subX
        } else if x <= 0 {
            x = 16
        }
        
        // Calculate Y position (prefer below target rect)
        var y = tooltip.rect.maxY + padding + tooltipHeight
        var anchorPosition: TooltipAnchorPosition = .top
        
        // Clamp Y to ensure tooltip stays within screen bounds
        let minY = safeAreaInsets.top + padding
        let maxY = screenSize.height - safeAreaInsets.bottom - padding - tooltipHeight
        
        if y > maxY {
            // Try above target rect
            let potentialY = tooltip.rect.minY - padding - tooltipHeight
            y = potentialY >= minY ? potentialY : min(maxY, max(minY, tooltip.rect.midY))
            anchorPosition = .bottom
        } else {
            y = tooltip.rect.maxY + padding
            anchorPosition = .top
        }
        
        let position = CGPoint(x: x, y: y)
        return (position, anchorPosition)
    }
}
