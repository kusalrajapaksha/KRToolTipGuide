//
//  ContentView.swift
//  KRToolTipGuideExampleApp
//
//  Created by Kusal on 2025-08-06.
//

import SwiftUI
import KRToolTipGuide

struct ContentView: View {
    var body: some View {
        BasicExampleView()
//        ScrollableExampleView()
//        CustomStyledTooltipExample()
    }
}

struct BasicExampleView: View {
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("KRToolTipGuide")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .captureTooltipFrame(tag: "title")
                
                Spacer()
                
                // Main content area
                VStack(spacing: 15) {
                    Button("Primary Action") {
                        // Primary action
                    }
                    .buttonStyle(.borderedProminent)
                    .captureTooltipFrame(tag: "primary_button")
                    
                    Button("Secondary Action") {
                        // Secondary action
                    }
                    .buttonStyle(.bordered)
                    .captureTooltipFrame(tag: "secondary_button")
                }
                
                Spacer()
                
                // Bottom navigation area
                HStack {
                    Button("Help") {
                        startTooltipGuide()
                    }
                    .captureTooltipFrame(tag: "help_button")
                    
                    Spacer()
                    
                    Button("Settings") {
                        showSettings = true
                    }
                    .captureTooltipFrame(tag: "settings_button")
                }
                .padding()
            }
            .padding()
            .navigationBarHidden(true)
            .setupTooltipGuide(tags: [
                "title",
                "primary_button",
                "secondary_button",
                "help_button",
                "settings_button"
            ])
        }
    }
    
    private func startTooltipGuide() {
        let steps = [
            TooltipData(
                viewTag: "title",
                message: "Welcome to the app! This is the main title."
            ),
            TooltipData(
                viewTag: "primary_button",
                message: "This is your primary action button. Tap it to get started with the main feature."
            ),
            TooltipData(
                viewTag: "secondary_button",
                message: "Use this secondary button for additional options."
            ),
            TooltipData(
                viewTag: "settings_button",
                message: "Access app settings and preferences here."
            ),
            TooltipData(
                viewTag: "help_button",
                message: "Tap here anytime to restart this tutorial!"
            )
        ]
        
        // Use MainActor method directly since we're in a SwiftUI context
        TooltipGuide.startGuide(steps)
    }
}

// Example with ScrollView and custom tags
struct ScrollableExampleView: View {
    enum FeatureTags: String, TooltipTagProtocol {
        case header = "feature_header"
        case searchBar = "search_bar"
        case filterButton = "filter_button"
        case listItem = "list_item"
        case addButton = "add_button"
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    // Header section
                    HStack {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .captureTooltipFrame(tag: FeatureTags.header)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .captureTooltipFrame(tag: FeatureTags.filterButton)
                    }
                    .padding(.horizontal)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search features...", text: .constant(""))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .captureTooltipFrame(tag: FeatureTags.searchBar)
                    
                    // Feature list
                    LazyVStack(spacing: 12) {
                        ForEach(0..<20, id: \.self) { index in
                            FeatureRow(title: "Feature \(index + 1)", index: index)
                                .id("feature_\(index)")
                                .captureTooltipFrame(tag: index == 0 ? FeatureTags.listItem.rawValue : "feature_\(index)")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .captureTooltipFrame(tag: FeatureTags.addButton)
                .padding()
            }
            .setupTooltipGuide(tags: [
                FeatureTags.header.rawValue,
                FeatureTags.searchBar.rawValue,
                FeatureTags.filterButton.rawValue,
                FeatureTags.listItem.rawValue,
                FeatureTags.addButton.rawValue
            ])
            .onAppear {
                Task { @MainActor in
                    TooltipGuide.setScrollProxy(proxy)
                    startFeatureGuide()
                }
            }
        }
    }
    
    private func startFeatureGuide() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let steps = [
                TooltipData(
                    viewTag: FeatureTags.header.rawValue,
                    message: "This is the features section where you can browse all available features."
                ),
                TooltipData(
                    viewTag: FeatureTags.searchBar.rawValue,
                    message: "Use the search bar to quickly find specific features."
                ),
                TooltipData(
                    viewTag: FeatureTags.filterButton.rawValue,
                    message: "Filter features by category or type using this button."
                ),
                TooltipData(
                    viewTag: FeatureTags.listItem.rawValue,
                    message: "Each row represents a feature. Tap to view details.",
                    scrollID: "feature_0"
                ),
                TooltipData(
                    viewTag: FeatureTags.addButton.rawValue,
                    message: "Create new features using this floating action button."
                )
            ]
            
            Task { @MainActor in
                TooltipGuide.startGuide(steps)
            }
        }
    }
}

struct FeatureRow: View {
    let title: String
    let index: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.medium)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text("Description for \(title.lowercased())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// Example with custom configuration
struct CustomStyledTooltipExample: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Custom Styled Tooltips")
                .font(.title)
                .captureTooltipFrame(tag: "custom_title")
            
            Button("Dark Theme Example") {
                startDarkThemeGuide()
            }
            .captureTooltipFrame(tag: "dark_button")
            
            Button("Colorful Example") {
                startColorfulGuide()
            }
            .captureTooltipFrame(tag: "colorful_button")
        }
        .setupTooltipGuide(tags: ["custom_title", "dark_button", "colorful_button"])
    }
    
    private func startDarkThemeGuide() {
        let darkConfig = TooltipOverlayConfiguration(
            dimOpacity: 0.8,
            backgroundColor: .black,
            textColor: .white,
            skipButtonText: "Skip Dark Guide",
            nextButtonText: "Continue",
            doneButtonText: "Finish"
        )
        
        // You would need to modify TooltipManager to accept configuration
        // This is a conceptual example
        let steps = [
            TooltipData(viewTag: "custom_title", message: "Dark themed tooltip!"),
            TooltipData(viewTag: "dark_button", message: "This uses a dark theme configuration.")
        ]
        
        TooltipGuide.startGuide(steps, configuration: darkConfig)
    }
    
    private func startColorfulGuide() {
        let colorfulConfig = TooltipOverlayConfiguration(
            backgroundColor: .purple,
            textColor: .white,
            skipButtonText: "Skip Colorful Guide"
        )
        
        let steps = [
            TooltipData(viewTag: "custom_title", message: "Colorful tooltip design!"),
            TooltipData(viewTag: "colorful_button", message: "Purple themed tooltips look great!")
        ]
        
        TooltipGuide.startGuide(steps, configuration: colorfulConfig)
    }
}


#Preview {
    ContentView()
}

