import Foundation
import SmokeOperations

public struct BluetoothInput: Codable, Validatable {
    static let jsonDecoder = JSONDecoder()
    
    public let bluetoothState: String
    
    var isOn: Bool { return bluetoothState == "on" }
    
    public init(bluetoothState: String) {
        self.bluetoothState = bluetoothState.lowercased() == "on" ? "on" : "off"
    }
    
    public init?(data: Data) {
        guard let decodedSelf = try? BluetoothInput.jsonDecoder.decode(BluetoothInput.self, from: data) else {
            return nil
        }
        self = decodedSelf
    }
    
    public func validate() throws {
        return
    }
}

extension BluetoothInput : Equatable {
    public static func ==(lhs: BluetoothInput, rhs: BluetoothInput) -> Bool {
        return lhs.bluetoothState == rhs.bluetoothState
    }
}

extension BluetoothInput: CustomStringConvertible {
    public var description: String { return "BluetoothInput(bluetoothState: \"\(bluetoothState)\")" }
}
