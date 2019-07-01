//
//  CustomService.swift
//  Assignment4PackageDescription
//
//  Created by Van Simmons on 4/1/19.
//

import Foundation
import Bluetooth
#if os(Linux)
import GATT
import BluetoothLinux
#elseif os(macOS)
import DarwinGATT
import BluetoothDarwin
#endif

public final class GATTCustomServiceController: GATTServiceController {
    public static let service: BluetoothUUID =
        BluetoothUUID(uuid: UUID(uuidString: "D9769299-8F32-4E0D-B0A3-4E2806BF8504")!)
 
    public let peripheral: PeripheralManager
    
    public private(set) var readValue = ""
    public private(set) var notifyValue = ""
    public private(set) var writeValue = ""
    
    internal let serviceHandle: UInt16
    
    internal let readHandle: UInt16
    internal let notifyHandle: UInt16
    internal let writeHandle: UInt16
    
    // MARK: - Initialization
    
    public init(peripheral: PeripheralManager) throws {
        self.peripheral = peripheral
        let serviceUUID = type(of: self).service
        
        #if os(Linux)
        let descriptors = [GATTClientCharacteristicConfiguration().descriptor]
        #else
        let descriptors: [GATT.Descriptor] = []
        #endif
        
        let readUuid = BluetoothUUID(uuid: UUID(uuidString: "549A25ED-D66D-4EAA-A85D-9C7C3F300698")!)
        let notifyUuid = BluetoothUUID(uuid: UUID(uuidString: "F97CFD9F-CEA6-43BA-B33F-3A4DDA15DAE1")!)
        let writeUuid = BluetoothUUID(uuid: UUID(uuidString: "39F9DEC8-4FB3-49B6-977A-E09991A5F417")!)
        
        let characteristics = [
            GATT.Characteristic(uuid: readUuid,
                                value: readValue.data(using: .utf8)!,
                                permissions: [.read],
                                properties: [.read],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: notifyUuid,
                                value: notifyValue.data(using: .utf8)!,
                                permissions: [.read],
                                properties: [.notify],
                                descriptors: descriptors),
            
            GATT.Characteristic(uuid: writeUuid,
                                value: writeValue.data(using: .utf8)!,
                                permissions: [.read, .write],
                                properties: [.read, .write],
                                descriptors: descriptors)
        ]
        
        let service = GATT.Service(uuid: serviceUUID,
                                   primary: true,
                                   characteristics: characteristics)
        
        self.serviceHandle = try peripheral.add(service: service)
        self.readHandle = peripheral.characteristics(for: readUuid)[0]
        self.notifyHandle = peripheral.characteristics(for: notifyUuid)[0]
        self.writeHandle = peripheral.characteristics(for: writeUuid)[0]
        
        updateValues()
    }
    
    deinit {
        self.peripheral.remove(service: serviceHandle)
    }
    
    // MARK: - Methods
    
    func updateValues() {
        readValue = "Read"
        writeValue = "Write"
        notifyValue = "Notify"
        
        peripheral[characteristic: readHandle] = readValue.data(using: .utf8)!
        peripheral[characteristic: notifyHandle] = notifyValue.data(using: .utf8)!
        peripheral[characteristic: writeHandle] = writeValue.data(using: .utf8)!
    }
}
