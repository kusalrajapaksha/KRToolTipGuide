//
//  TooltipOverlay.swift
//  KRToolTipGuide
//
//  Created by Kusal on 2025-08-05.
//

import SwiftUI

/// Configuration for tooltip overlay appearance
@MainActor
public struct TooltipOverlayConfiguration {
    public let dimOpacity: Double
    public let cornerRadius: CGFloat
    public let padding: CGFloat
    public let maxWidth: CGFloat
    public let backgroundColor: Color
    public let textColor: Color
    public let skipButtonText: String
    public let nextButtonText: String
    public let doneButtonText: String
    
    public init(
        dimOpacity: Double = 0.6,
        cornerRadius: CGFloat = 10,
        padding: CGFloat = 10,
        maxWidth: CGFloat = UIScreen.main.bounds.width / 3 * 2,
        backgroundColor: Color = .white,
        textColor: Color = .black,
        skipButtonText: String = "Skip Tutorial",
        nextButtonText: String = "Next",
        doneButtonText: String = "Done"
    ) {
        self.dimOpacity = dimOpacity
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.maxWidth = maxWidth
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.skipButtonText = skipButtonText
        self.nextButtonText = nextButtonText
        self.doneButtonText = doneButtonText
    }
    
    public static let `default` = TooltipOverlayConfiguration()
}

/// Overlay view that displays tooltips with dimmed background
public struct TooltipOverlay: View {
    @EnvironmentObject var manager: TooltipManager
    @State var tooltipSize: CGSize = .zero
    
    public let configuration: TooltipOverlayConfiguration
    
    public init(configuration: TooltipOverlayConfiguration = .default) {
        self.configuration = configuration
    }

    public var body: some View {
        GeometryReader { geo in
            if let tooltip = manager.currentTooltip, !tooltip.rect.isEmpty {
                ZStack {
                    // Dimmed background with cutout
                    Color.black.opacity(configuration.dimOpacity)
                        .ignoresSafeArea()
                        .mask(
                            Rectangle()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: tooltip.rect.width + 16, height: tooltip.rect.height + 16)
                                        .position(x: tooltip.rect.midX, y: tooltip.rect.midY)
                                        .blendMode(.destinationOut)
                                )
                        )
                        .compositingGroup()
                        .onTapGesture {
                            manager.next()
                        }

                    // Tooltip message
                    let safeAreaInsets = geo.safeAreaInsets
                    let tooltipPosition = TooltipWindowManager.calculateTooltipPosition(
                        tooltip: tooltip,
                        tooltipSize: tooltipSize,
                        screenSize: geo.size,
                        safeAreaInsets: safeAreaInsets
                    )
                    let anchorXOffset = max(0, tooltip.rect.minX - tooltipPosition.0.x) + 16

                    VStack {
                        HStack(alignment: .top) {
                            Text(tooltip.message)
                                .foregroundColor(configuration.textColor)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 0) {
                            Text("\(manager.currentIndex + 1)")
                                .foregroundColor(configuration.textColor)
                                .font(.system(size: 12))
                            
                            Text("/\(manager.tooltips.count)")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                            
                            Spacer()
                            
                            Button {
                                manager.next()
                            } label: {
                                if manager.tooltips.count == manager.currentIndex + 1 {
                                    Text(configuration.doneButtonText)
                                        .font(.system(size: 14))
                                } else {
                                    Text(configuration.nextButtonText)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                    .padding(configuration.padding)
                    .frame(maxWidth: configuration.maxWidth)
                    .background(configuration.backgroundColor)
                    .cornerRadius(configuration.cornerRadius)
                    .readSize($tooltipSize)
                    .overlay(alignment: .leading) {
                        if tooltipPosition.1 == .top {
                            Image(systemName: "arrowtriangle.up.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(configuration.backgroundColor)
                                .frame(height: 16)
                                .offset(x: anchorXOffset, y: -tooltipSize.height / 2)
                        } else {
                            Image(systemName: "arrowtriangle.down.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(configuration.backgroundColor)
                                .frame(height: 16)
                                .offset(x: anchorXOffset, y: tooltipSize.height / 2)
                        }
                    }
                    .position(x: tooltipPosition.0.x + tooltipSize.width / 2, y: tooltipPosition.0.y + tooltipSize.height / 2)
                }
            }
        }
        .ignoresSafeArea()
    }
}

/// Helper view modifier to read view size
private struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

private extension View {
    func readSize(_ size: Binding<CGSize>) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { newSize in
            size.wrappedValue = newSize
        }
    }
}
