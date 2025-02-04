//
//  BluetoothManager.swift
//  BloodyMaryChallenge Watch App
//
//  Created by Jan Armbrust on 04.02.2025.
//

import Foundation
import CoreBluetooth
import SwiftUI

final class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    
    // Store discovered peripherals, their RSSI, and their advertised local names.
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var peripheralRSSI: [UUID: NSNumber] = [:]
    @Published var peripheralLocalNames: [UUID: String] = [:]
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Convert an RSSI value to an estimated distance (in meters).
    /// This formula is rough and should be calibrated for your environment.
    func estimatedDistance(for rssi: NSNumber) -> Double {
        let measuredPower: Double = -59   // Expected RSSI at 1 meter (adjust as needed)
        let environmentalFactor: Double = 2.0 // Typical value in free space.
        let rssiValue = rssi.doubleValue
        guard rssiValue != 0 else { return -1.0 }
        return pow(10.0, (measuredPower - rssiValue) / (10 * environmentalFactor))
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Start scanning for peripherals (filtering can be added via service UUIDs as needed).
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning started...")
        } else {
            print("Central manager state: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        // Get the advertised local name.
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
           localName == "MyWatchApp" {
            // Add the peripheral if it's new.
            if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                discoveredPeripherals.append(peripheral)
            }
            // Store/update the RSSI and the local name.
            peripheralRSSI[peripheral.identifier] = RSSI
            peripheralLocalNames[peripheral.identifier] = localName
            print("Discovered \(localName) with RSSI: \(RSSI)")
        }
    }
}
