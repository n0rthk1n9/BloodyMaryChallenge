//
//  PeripheralManager.swift
//  BloodyMaryChallenge Watch App
//
//  Created by Jan Armbrust on 04.02.2025.
//

import CoreBluetooth
import SwiftUI

final class PeripheralManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    
    override init() {
        super.init()
        // Use the convenience initializer for watchOS.
        peripheralManager = CBPeripheralManager()
        // Assign the delegate manually.
        peripheralManager.delegate = self
    }
    
    // MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            // Start advertising with our local name.
            let advertisementData: [String: Any] = [CBAdvertisementDataLocalNameKey: "MyWatchApp"]
            peripheralManager.startAdvertising(advertisementData)
            print("Advertising started on watchOS")
        } else {
            peripheralManager.stopAdvertising()
            print("Advertising stopped; state: \(peripheral.state.rawValue)")
        }
    }
}
