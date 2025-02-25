//
//  MainView.swift
//  BloodyMaryChallenge Watch App
//
//  Created by Jan Armbrust on 03.02.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var bluetoothService = BluetoothService()
    @StateObject private var peripheralService = PeripheralService()
    @StateObject private var motionService: MotionService
    @StateObject private var heartRateService = HeartRateService()
    @State private var pulseArr: [PulseModel] = []

    // Add proximity threshold
    private let proximityThreshold: Double = 1.0  // 1 meter

    init() {
        // Initialize MotionService with BluetoothService
        let btService = BluetoothService()
        _bluetoothService = StateObject(wrappedValue: btService)
        _motionService = StateObject(wrappedValue: MotionService(bluetoothManager: btService))
    }

    var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if let otherPeripheral = bluetoothService.discoveredPeripherals.first(where: {
                    bluetoothService.peripheralLocalNames[$0.identifier] == "MyWatchApp"
                }),
                let rssi = bluetoothService.peripheralRSSI[otherPeripheral.identifier] {
                    let distance = bluetoothService.estimatedDistance(for: rssi)
                    
                    if distance <= proximityThreshold {
                        // Show motion visualization when close
                        TouchVisualizationView(motionManager: motionService)
                    } else {
                        // Show pulsing heart with distance warning
                        PulsingHeartView(
                            heartRateManager: heartRateService,
                            pulseArr: $pulseArr,
                            message: "Get\nCloser to Carolina!"
                        )
                    }
                } else {
                    // Show searching message with pulsing heart
                    PulsingHeartView(
                        heartRateManager: heartRateService,
                        pulseArr: $pulseArr,
                        message: "Open app\non other\ndevice"
                    )
                }
            }
            .onAppear {
                heartRateService.startMonitoring()
            }
        }
}

#Preview {
    MainView()
}
