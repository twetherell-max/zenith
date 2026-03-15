import SwiftUI
import CoreGraphics

struct ZenithDropletView: View {
    @Binding var isPulsing: Bool
    
    @ObservedObject var state = ZenithState.shared
    
    @State private var hoveredButton: Int? = nil 
    
    private var isExpanded: Bool {
        state.isExpanded || state.isSettingsOpen
    }
    
    private func getPosition(for id: Int) -> CGPoint {
        if !isExpanded {
            return CGPoint(x: 0, y: -100)
        }
        let xOffset = CGFloat(id - 2) * state.arcSpread
        let yPos = (abs(xOffset) * -0.2) + state.dropDepth 
        return CGPoint(x: xOffset, y: yPos)
    }
    
    var body: some View {
        ZStack(alignment: .top) { 
            // Radial Menu (Merged for Reification)
            ZStack { 
                 CrustButtonInternal(id: 1, icon: "folder", tooltip: "Downloads", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize) {
                    let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                    NSWorkspace.shared.open(downloadsURL)
                }
                .offset(x: getPosition(for: 1).x, y: getPosition(for: 1).y)
                .zIndex(1)
                
                CrustButtonInternal(id: 2, icon: "gearshape.fill", tooltip: "Settings", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize) {
                    // THE BOSS GEAR ACTION - HARD REIFIED LINK
                    AppDelegate.shared.showSettingsWindow()
                }
                .padding(10) 
                .contentShape(Rectangle()) 
                .offset(x: getPosition(for: 2).x, y: getPosition(for: 2).y)
                .zIndex(2)
                
                CrustButtonInternal(id: 3, icon: "moon.stars.fill", tooltip: "Toggle Dark Glass", isExpanded: isExpanded, hoveredButton: $hoveredButton, offset: .zero, iconSize: state.iconSize) {
                    state.isDarkGlass.toggle()
                }
                .offset(x: getPosition(for: 3).x, y: getPosition(for: 3).y)
                .zIndex(1)
            }
            .frame(width: 800, height: 100)
            
            // BRAIN ID ANCHOR
            Text("BRAIN ID: \(state.debugID)")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 2)
        }
        .onHover { hovering in
            if !state.isSettingsOpen {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    state.isExpanded = hovering
                }
            }
        }
        .frame(width: 800, height: 200)
        .contentShape(Rectangle()) 
        .background(Color.black.opacity(0.001)) 
    }
}

// INLINE COMPONENT FOR REIFICATION
struct CrustButtonInternal: View {
    let id: Int
    let icon: String
    let tooltip: String
    let isExpanded: Bool 
    @Binding var hoveredButton: Int?
    let offset: CGSize
    let iconSize: Double 
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
                        Circle().stroke(.white.opacity(0.4), lineWidth: 0.5)
                    ) 
                
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold)) 
                    .foregroundColor(hoveredButton == id ? .white : .white.opacity(0.8)) 
                    .frame(width: icon == "gearshape.fill" ? 60 : nil, height: icon == "gearshape.fill" ? 60 : nil) 
                    .contentShape(Rectangle()) 
            }
        }
        .frame(width: iconSize * 1.5, height: iconSize * 1.5) 
        .contentShape(Circle()) 
        .offset(offset) 
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isExpanded) 
        .scaleEffect(hoveredButton == id ? 1.2 : 1.0) 
        .onHover { isHovered in
            hoveredButton = isHovered ? id : nil
        }
        .help(tooltip) 
    }
}
