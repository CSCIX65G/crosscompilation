import Foundation
import SmokeOperations

public struct ClockOutput: Codable, Validatable {
    public let output: String
    
    public init(output: String) {
        self.output = output
    }
    
    public func validate() throws { }
}

extension ClockOutput : Equatable {
    public static func ==(lhs: ClockOutput, rhs: ClockOutput) -> Bool {
        return lhs.output == rhs.output
    }
}

extension ClockOutput: CustomStringConvertible {
    public var description: String { return "ClockOutput(output: \"\(output)\")" }
}
