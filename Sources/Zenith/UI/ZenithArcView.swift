import SwiftUI
import CoreGraphics

struct ZenithArcView: View {
    @ObservedObject var state = ZenithState.shared
    @State private var isHovering = false
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let notchY: CGFloat = 22

            ZStack {
                // Invisible hover trigger
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        isHovering = hovering
                        if hovering && state.currentLevel == 1 {
                            state.isExpanded = true
                        }
                    }

                // Always show radial dock visuals
                ZStack {
                    GravityWellGlow(centerX: centerX, notchY: notchY)
                    GravityWellTiles(
                        segments: state.visibleSegments,
                        centerX: centerX,
                        notchY: notchY
                    )
                }

                // Back button on deeper levels
                if state.currentLevel > 1 {
                    BackButton()
                        .position(x: centerX - 100, y: notchY - 35)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: state.isExpanded)
        }
    }
}

// Enhanced gravity-well glow effect
struct GravityWellGlow: View {
    let centerX: CGFloat
    let notchY: CGFloat
    
    var body: some View {
        ZStack {
            // Outer radial glow - energy radiating outward
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.05),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .position(x: centerX, y: notchY + 30)
            
            // Middle energy ring
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
                .position(x: centerX, y: notchY + 30)
            
            // Camera lens housing - the source of gravity well
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                    .position(x: centerX, y: notchY + 30)
                
                // Inner black lens
                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: 14, height: 14)
                    .position(x: centerX, y: notchY + 30)
                
                // Lens reflection
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 5, height: 5)
                    .position(x: centerX - 3, y: notchY + 27)
            }
        }
    }
}

// Gravity-well tiles with connector lines
struct GravityWellTiles: View {
    let segments: [ArcSegment]
    let centerX: CGFloat
    let notchY: CGFloat
    
    @ObservedObject var state = ZenithState.shared
    
    var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                GravityWellTile(
                    segment: segment,
                    index: index,
                    totalCount: segments.count,
                    centerX: centerX,
                    notchY: notchY
                )
            }
        }
    }
}

// Individual tile with gravity-well positioning and connector
struct GravityWellTile: View {
    let segment: ArcSegment
    let index: Int
    let totalCount: Int
    let centerX: CGFloat
    let notchY: CGFloat
    
    @ObservedObject var state = ZenithState.shared
    @State private var isHovered = false
    
    // Calculate position - stems from camera edges
    private var position: CGPoint {
        // Start from camera edges and arc downward
        let cameraWidth: CGFloat = 20 // Width of camera housing
        let startOffset = cameraWidth / 2 + 8 // Start just outside camera
        
        // Left to right across camera
        let startX = centerX - startOffset
        let endX = centerX + startOffset
        let arcWidth = endX - startX
        let arcDepth: CGFloat = 50 // How far down the arc goes
        
        let t = CGFloat(index) / CGFloat(max(totalCount - 1, 1))
        
        // Horizontal position - spread from camera edges outward
        let x = centerX + (t - 0.5) * 80
        
        // Vertical position - arc downward from camera
        // Use cosine for smooth downward arc
        let baseY = notchY + 30 + cameraWidth / 2
        let arcY = baseY + arcDepth * sin(t * .pi)
        
        return CGPoint(x: x, y: arcY)
    }
    
    // Rotation follows the arc curve
    private var rotation: Angle {
        let t = CGFloat(index) / CGFloat(max(totalCount - 1, 1))
        let angle = cos(t * .pi) * 45
        return .degrees(Double(angle))
    }
    
    var body: some View {
        ZStack {
            // Connector line from camera to tile - energy beam
            ConnectorLine(
                startX: centerX,
                startY: notchY + 30,
                endX: position.x,
                endY: position.y,
                isHovered: isHovered
            )
            
            // Glass square tile
            GlassTileFrame(isHovered: isHovered) {
                Image(systemName: segment.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .position(position)
        .rotationEffect(rotation)
        .scaleEffect(isHovered ? 1.2 : 1.0)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// Energy connector line from camera
struct ConnectorLine: View {
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let isHovered: Bool
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        .stroke(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(isHovered ? 0.6 : 0.25),
                    Color.white.opacity(isHovered ? 0.3 : 0.1),
                    Color.clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: isHovered ? 2 : 1, lineCap: .round)
        )
    }
}

// Glass square tile with HUD frame
struct GlassTileFrame<Content: View>: View {
    let isHovered: Bool
    let content: () -> Content
    
    init(isHovered: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.isHovered = isHovered
        self.content = content
    }
    
    var body: some View {
        ZStack {
            // Glass background with frosted material
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.42),
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.32)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.ultraThinMaterial)
                )
                .frame(width: 38, height: 38)
            
            // White bordered frame
            RoundedRectangle(cornerRadius: 3)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(isHovered ? 1.0 : 0.82),
                            Color.white.opacity(isHovered ? 0.92 : 0.58)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isHovered ? 2.2 : 1.4
                )
                .frame(width: 38, height: 38)
            
            // Soft diffused neon glow
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.clear)
                .frame(width: 38, height: 38)
                .shadow(
                    color: Color.white.opacity(isHovered ? 0.98 : 0.58),
                    radius: isHovered ? 24 : 15,
                    x: 0,
                    y: 0
                )
            
            // Icon content
            content()
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.72), value: isHovered)
    }
}

struct BackButton: View {
    @ObservedObject var state = ZenithState.shared
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                state.collapseToLevel(1)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.24))
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.68), lineWidth: 1.2)
                    )
                    .shadow(color: .white.opacity(0.58), radius: 15)
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
