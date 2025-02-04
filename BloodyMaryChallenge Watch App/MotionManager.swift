//
//  MotionManager.swift
//  BloodyMaryChallenge Watch App
//
//  Created by Jan Armbrust on 04.02.2025.
//

import SwiftUI
import CoreMotion
import WatchKit

@MainActor
class MotionManager: ObservableObject {
    // Raw accelerometer values.
    @Published var x: Double = 0
    @Published var y: Double = 0
    @Published var z: Double = 0

    // Animation properties for the circles.
    @Published var xScale: CGFloat = 1.0
    @Published var yScale: CGFloat = 1.0
    @Published var zScale: CGFloat = 1.0

    @Published var xOpacity: Double = 0.0
    @Published var yOpacity: Double = 0.0
    @Published var zOpacity: Double = 0.0

    @Published var xOffset: CGSize = .zero
    @Published var yOffset: CGSize = .zero
    @Published var zOffset: CGSize = .zero

    private let motionManager = CMMotionManager()
    private let updateInterval = 0.1

    // Timestamps to throttle haptic feedback per axis.
    private var lastXHapticTime = Date.distantPast
    private var lastYHapticTime = Date.distantPast
    private var lastZHapticTime = Date.distantPast

    init() {
        startUpdates()
    }

    // MARK: - Haptic Function

    /// Triggers haptic feedback of the specified type.
    private func triggerHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }

    // MARK: - Animation Function

    /// Animates a pulse effect (scale up and fade in, then revert) for a given axis.
    private func animatePulse(scaleKeyPath: ReferenceWritableKeyPath<MotionManager, CGFloat>,
                                opacityKeyPath: ReferenceWritableKeyPath<MotionManager, Double>) async {
        withAnimation(.easeOut(duration: 0.2)) {
            self[keyPath: scaleKeyPath] = 1.5
            self[keyPath: opacityKeyPath] = 1.0
        }
        // Await a 200-millisecond pause.
        try? await Task.sleep(nanoseconds: 200_000_000)
        withAnimation(.easeIn(duration: 0.5)) {
            self[keyPath: scaleKeyPath] = 1.0
            self[keyPath: opacityKeyPath] = 0.0
        }
    }

    // MARK: - Combined Feedback Function

    /// Triggers both haptic and animation feedback.
    private func triggerFeedback(hapticType: WKHapticType,
                                 scaleKeyPath: ReferenceWritableKeyPath<MotionManager, CGFloat>,
                                 opacityKeyPath: ReferenceWritableKeyPath<MotionManager, Double>) async {
        triggerHaptic(hapticType)
        await animatePulse(scaleKeyPath: scaleKeyPath, opacityKeyPath: opacityKeyPath)
    }

    // MARK: - Motion Updates

    func startUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }
        motionManager.accelerometerUpdateInterval = updateInterval

        // Wrap accelerometer updates in an AsyncStream.
        let stream = AsyncStream<CMAccelerometerData>(bufferingPolicy: .unbounded) { continuation in
            self.motionManager.startAccelerometerUpdates(to: OperationQueue.main) { data, error in
                if let data = data {
                    continuation.yield(data)
                }
                if error != nil {
                    continuation.finish()
                }
            }
            continuation.onTermination = { _ in
                self.motionManager.stopAccelerometerUpdates()
            }
        }

        Task {
            var previousX: Double?
            var previousY: Double?
            var previousZ: Double?

            // Thresholds for significant change.
            let xThreshold = 0.3
            let yThreshold = 0.3
            let zThreshold = 0.4

            // Haptic throttling interval.
            let hapticInterval: TimeInterval = 1.0

            for await data in stream {
                // Update raw values.
                self.x = data.acceleration.x
                self.y = data.acceleration.y
                self.z = data.acceleration.z

                // Update offsets for visualization.
                self.xOffset = CGSize(width: CGFloat(data.acceleration.x) * 50, height: 0)
                self.yOffset = CGSize(width: 0, height: CGFloat(data.acceleration.y) * 50)
                self.zOffset = CGSize(width: CGFloat(data.acceleration.z) * 50,
                                      height: CGFloat(data.acceleration.z) * 50)

                let now = Date()

                // X-axis feedback.
                if let prevX = previousX {
                    let deltaX = abs(data.acceleration.x - prevX)
                    if deltaX > xThreshold && now.timeIntervalSince(lastXHapticTime) > hapticInterval {
                        lastXHapticTime = now
                        Task {
                            await self.triggerFeedback(hapticType: .success,
                                                       scaleKeyPath: \.xScale,
                                                       opacityKeyPath: \.xOpacity)
                            await self.triggerFeedback(hapticType: .failure,
                                                       scaleKeyPath: \.xScale,
                                                       opacityKeyPath: \.xOpacity)
                        }
                    }
                }
                previousX = data.acceleration.x

                // Y-axis feedback.
                if let prevY = previousY {
                    let deltaY = abs(data.acceleration.y - prevY)
                    if deltaY > yThreshold && now.timeIntervalSince(lastYHapticTime) > hapticInterval {
                        lastYHapticTime = now
                        Task {
                            await self.triggerFeedback(hapticType: .success,
                                                       scaleKeyPath: \.yScale,
                                                       opacityKeyPath: \.yOpacity)
                            await self.triggerFeedback(hapticType: .failure,
                                                       scaleKeyPath: \.yScale,
                                                       opacityKeyPath: \.yOpacity)
                        }
                    }
                }
                previousY = data.acceleration.y

                // Z-axis feedback.
                if let prevZ = previousZ {
                    let deltaZ = abs(data.acceleration.z - prevZ)
                    if deltaZ > zThreshold && now.timeIntervalSince(lastZHapticTime) > hapticInterval {
                        lastZHapticTime = now
                        Task {
                            await self.triggerFeedback(hapticType: .success,
                                                       scaleKeyPath: \.zScale,
                                                       opacityKeyPath: \.zOpacity)
                            await self.triggerFeedback(hapticType: .failure,
                                                       scaleKeyPath: \.zScale,
                                                       opacityKeyPath: \.zOpacity)
                        }
                    }
                }
                previousZ = data.acceleration.z
            }
        }
    }
}
