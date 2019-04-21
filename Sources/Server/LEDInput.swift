//
//  LEDInput.swift
//  Bluetooth
//
//  Created by Van Simmons on 4/21/19.
//

import Foundation
import SmokeOperations

public struct LEDInput: Codable, Validatable {
    static let jsonDecoder = JSONDecoder()
    
    public let ledState: String
    
    var isOn: Bool { return ledState == "on" }
    
    public init(ledState: String) {
        self.ledState = ledState.lowercased() == "on" ? "on" : "off"
    }
    
    public init?(data: Data) {
        guard let decodedSelf = try? LEDInput.jsonDecoder.decode(LEDInput.self, from: data) else {
            return nil
        }
        self = decodedSelf
    }
    
    public func validate() throws {
        return
    }
}

extension LEDInput : Equatable {
    public static func ==(lhs: LEDInput, rhs: LEDInput) -> Bool {
        return lhs.ledState == rhs.ledState
    }
}

extension LEDInput: CustomStringConvertible {
    public var description: String { return "LEDInput(ledState: \"\(ledState)\")" }
}
