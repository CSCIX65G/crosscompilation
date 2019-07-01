import Foundation
import SmokeOperations

public struct BluetoothOutput: Codable, Validatable {
    public let bluetoothState: String
    
    public init(bluetoothState: String) {
        self.bluetoothState = bluetoothState
    }
    
    public init(bluetoothState: Bool) {
        self.bluetoothState = bluetoothState ? "on" : "off"
    }
    
    public func validate() throws { }
}

extension BluetoothOutput : Equatable {
    public static func ==(lhs: BluetoothOutput, rhs: BluetoothOutput) -> Bool {
        return lhs.bluetoothState == rhs.bluetoothState
    }
}

extension BluetoothOutput: CustomStringConvertible {
    public var description: String { return "BluetoothOutput(bluetoothState: \"\(bluetoothState)\")" }
}
