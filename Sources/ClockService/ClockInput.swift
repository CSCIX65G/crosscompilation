import Foundation
import SmokeOperations

public struct ClockInput: Codable, Validatable {
    public let input: String
    
    public init(input: String) {
        self.input = input
    }
    
    public func validate() throws {
        return
    }
}

extension ClockInput : Equatable {
    public static func ==(lhs: ClockInput, rhs: ClockInput) -> Bool {
        return lhs.input == rhs.input
    }
}

extension ClockInput: CustomStringConvertible {
    public var description: String { return "ClockInput(input: \"\(input)\")" }
}
