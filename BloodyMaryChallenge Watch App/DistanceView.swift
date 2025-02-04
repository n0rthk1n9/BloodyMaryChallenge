//
//  DistanceView.swift
//  BloodyMaryChallenge Watch App
//
//  Created by Jan Armbrust on 04.02.2025.
//

import SwiftUI

import SwiftUI

struct DistanceView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var peripheralManager = PeripheralManager() // Assuming you're using the watchOS-friendly version.
    
    var body: some View {
        VStack(spacing: 20) {
            // Look for a discovered peripheral where the stored local name equals "MyWatchApp"
            if let otherPeripheral = bluetoothManager.discoveredPeripherals.first(where: {
                bluetoothManager.peripheralLocalNames[$0.identifier] == "MyWatchApp"
            }),
            let rssi = bluetoothManager.peripheralRSSI[otherPeripheral.identifier] {
                let distance = bluetoothManager.estimatedDistance(for: rssi)
                Text("Distance:")
                    .font(.headline)
                Text("\(distance, specifier: "%.2f") meters")
                    .font(.largeTitle)
            } else {
                Text("Searching for device...")
                    .font(.headline)
            }
        }
        .padding()
        .onAppear {
            print("DistanceView appeared. Scanning and advertising are active.")
        }
    }
}

#Preview {
    DistanceView()
}
