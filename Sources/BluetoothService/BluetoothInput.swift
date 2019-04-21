import Foundation
import SmokeOperations

public struct BluetoothInput: Codable, Validatable {
    public let input: String
    
    public init(input: String) {
        self.input = input
    }
    
    public func validate() throws {
        return
    }
}

extension BluetoothInput : Equatable {
    public static func ==(lhs: BluetoothInput, rhs: BluetoothInput) -> Bool {
        return lhs.input == rhs.input
    }
}

extension BluetoothInput: CustomStringConvertible {
    public var description: String { return "BluetoothInput(input: \"\(input)\")" }
}
