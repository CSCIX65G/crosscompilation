import Foundation
import SmokeOperations

public struct BluetoothOutput: Codable, Validatable {
    public let output: String
    
    public init(output: String) {
        self.output = output
    }
    
    public func validate() throws { }
}

extension BluetoothOutput : Equatable {
    public static func ==(lhs: BluetoothOutput, rhs: BluetoothOutput) -> Bool {
        return lhs.output == rhs.output
    }
}

extension BluetoothOutput: CustomStringConvertible {
    public var description: String { return "BluetoothOutput(output: \"\(output)\")" }
}
