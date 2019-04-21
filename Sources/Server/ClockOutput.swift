import Foundation
import SmokeOperations

public struct ClockOutput: Codable, Validatable {
    public let clockState: String
    
    public init(clockState: String) {
        self.clockState = clockState
    }
    
    public init(clockState: Bool) {
        self.clockState = clockState ? "on" : "off"
    }
    
    public func validate() throws { }
}

extension ClockOutput : Equatable {
    public static func ==(lhs: ClockOutput, rhs: ClockOutput) -> Bool {
        return lhs.clockState == rhs.clockState
    }
}

extension ClockOutput: CustomStringConvertible {
    public var description: String { return "ClockOutput(clockState: \"\(clockState)\")" }
}
