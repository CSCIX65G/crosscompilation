import Foundation
import SmokeOperations

public struct ClockInput: Codable, Validatable {
    static let jsonDecoder = JSONDecoder()

    public let clockState: String

    var isOn: Bool { return clockState == "on" }
    
    public init(clockState: String) {
        self.clockState = clockState.lowercased() == "on" ? "on" : "off"
    }
    
    public init?(data: Data) {
        guard let decodedSelf = try? ClockInput.jsonDecoder.decode(ClockInput.self, from: data) else {
            return nil
        }
        self = decodedSelf
    }
    
    public func validate() throws {
        return
    }
}

extension ClockInput : Equatable {
    public static func ==(lhs: ClockInput, rhs: ClockInput) -> Bool {
        return lhs.clockState == rhs.clockState
    }
}

extension ClockInput: CustomStringConvertible {
    public var description: String { return "ClockInput(clockState: \"\(clockState)\")" }
}
