import SwiftUI

struct TouchVisualizationView: View {
    @ObservedObject var motionManager: MotionService
    
    var body: some View {
        ZStack {
            // X-axis circle (red)
            Circle()
                .fill(Color.red)
                .frame(width: 40, height: 40)
                .scaleEffect(motionManager.xScale)
                .offset(motionManager.xOffset)
                .opacity(motionManager.xOpacity)
            
            // Y-axis circle (green)
            Circle()
                .fill(Color.green)
                .frame(width: 40, height: 40)
                .scaleEffect(motionManager.yScale)
                .offset(motionManager.yOffset)
                .opacity(motionManager.yOpacity)
            
            // Z-axis circle (blue)
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .scaleEffect(motionManager.zScale)
                .offset(motionManager.zOffset)
                .opacity(motionManager.zOpacity)
        }
    }
}
