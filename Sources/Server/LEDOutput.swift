//
//  LEDOutput.swift
//  Bluetooth
//
//  Created by Van Simmons on 4/21/19.
//

import Foundation
import SmokeOperations

public struct LEDOutput: Codable, Validatable {
    public let ledState: String
    
    public init(ledState: String) {
        self.ledState = ledState
    }
    
    public init(ledState: Bool) {
        self.ledState = ledState ? "on" : "off"
    }
    
    public func validate() throws { }
}

extension LEDOutput : Equatable {
    public static func ==(lhs: LEDOutput, rhs: LEDOutput) -> Bool {
        return lhs.ledState == rhs.ledState
    }
}

extension LEDOutput: CustomStringConvertible {
    public var description: String { return "LEDOutput(ledState: \"\(ledState)\")" }
}
