import SwiftUI
import CoreGraphics

struct ZenithCrustView: View {
    let isHovering: Bool
    
    @ObservedObject var state = ZenithState.shared
    
    @State private var hoveredButton: Int? = nil 
    
    private var isExpanded: Bool {
        isHovering || state.isSettingsOpen
    }
    
    private func getPosition(for id: Int) -> CGPoint {
        if !isExpanded {
            return CGPoint(x: 0, y: -100)
        }
        
        let xOffset = CGFloat(id - 2) * state.arcSpread
        let yPos = (abs(xOffset) * -0.2) + state.dropDepth // SMILE MATH Restored
        
        return CGPoint(x: xOffset, y: yPos)
    }
    
    var body: some View {
        ZStack(alignment: .top) { 
            VStack {
                ZStack { 
                    CrustButton(id: 1, icon: "folder", tooltip: "Downloads", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize, isDarkGlass: state.isDarkGlass, isSettingsOpen: state.isSettingsOpen) {
                        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                        NSWorkspace.shared.open(downloadsURL)
                    }
                    .offset(x: getPosition(for: 1).x, y: getPosition(for: 1).y)
                    .zIndex(1)
                    
                    CrustButton(id: 2, icon: "gearshape.fill", tooltip: "Settings", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize, isDarkGlass: state.isDarkGlass, isSettingsOpen: state.isSettingsOpen) {
                        NSApp.activate(ignoringOtherApps: true)
                        AppDelegate.shared.showSettingsWindow()
                    }
                    .padding(10) 
                    .contentShape(Rectangle()) 
                    .offset(x: getPosition(for: 2).x, y: getPosition(for: 2).y)
                    .zIndex(2)
                    
                    CrustButton(id: 3, icon: "moon.stars.fill", tooltip: "Toggle Dark Glass", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize, isDarkGlass: state.isDarkGlass, isSettingsOpen: state.isSettingsOpen) {
                        state.isDarkGlass.toggle()
                    }
                    .offset(x: getPosition(for: 3).x, y: getPosition(for: 3).y)
                    .zIndex(1)
                }
                .frame(width: 800, height: 100)
                .zIndex(5) 
            }
            .frame(width: 800, height: 250) 
            .background(Color.black.opacity(0.01)) 
        }
        .frame(width: 800, height: 200)
    }
}

struct CrustButton: View {
    let id: Int
    let icon: String
    let tooltip: String
    let isExpanded: Bool 
    @Binding var hoveredButton: Int?
    let offset: CGSize
    let iconSize: Double 
    let isDarkGlass: Bool 
    let isSettingsOpen: Bool 
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2)) 
                    .background(Circle().fill(.thickMaterial)) 
                    .frame(width: iconSize * 2.2, height: iconSize * 2.2) 
                    .shadow(color: hoveredButton == id ? .white : .black.opacity(0.8), radius: hoveredButton == id ? 15 : 10) 
                    .overlay(
                        Circle()
                            .stroke((id == 2 && isSettingsOpen) ? Color.white : .white.opacity(0.4), lineWidth: (id == 2 && isSettingsOpen) ? 2 : 0.5)
                            .shadow(color: (id == 2 && isSettingsOpen) ? .white : .clear, radius: 5)
                    ) 
                
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .semibold)) 
                        .foregroundColor(hoveredButton == id ? .white : .white.opacity(0.8)) 
                    
                    if id == 2 && isSettingsOpen {
                        Text("OPEN")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: icon == "gearshape.fill" ? 60 : nil, height: icon == "gearshape.fill" ? 60 : nil) 
                .contentShape(Rectangle()) 
            }
            .environment(\.colorScheme, isDarkGlass ? .dark : .light) 
        }
        .frame(width: iconSize * 1.5, height: iconSize * 1.5) 
        .contentShape(Circle()) 
        .offset(offset) 
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isExpanded) 
        .scaleEffect(hoveredButton == id ? 1.2 : 1.0) 
        .blur(radius: (hoveredButton != nil && hoveredButton != id) ? 0.5 : 0) 
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: hoveredButton) 
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: iconSize) 
        .onHover { isHovered in
            hoveredButton = isHovered ? id : nil
        }
        .help(tooltip) 
    }
}
