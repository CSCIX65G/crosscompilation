//
//  GPIOInput.swift
//  Bluetooth
//
//  Created by Van Simmons on 4/21/19.
//

import Foundation
import SwiftyLinkerKit
import HeliumLogger
import LoggerAPI

struct GPIOInput {
    static let logger = HeliumLogger()
    static let button = LKButton2()
    static let touchSensor = LKButton2()

    static func handleButtons() {
        guard let shield  = LKRBShield.default else { return }
        Log.logger = logger

        shield.connect(button, to: .digital2627)
        button.onPress1 {
            Log.info("Button 1 was pressed!")
            LEDService.led.on = !LEDService.led.on
        }
        button.onChange1 { isPressed in
            Log.info("Button 1 changed, it is now: \(isPressed ? "pressed" : "off" )")
        }

        shield.connect(touchSensor, to: .digital2122)
        touchSensor.onPress1 {
            Log.info("Sensor was touched!")
        }
        touchSensor.onChange1 { isPressed in
            Log.info("Sensor changed, it is now: \(isPressed ? "touched" : "off" )")
            LEDService.led.on = !LEDService.led.on
        }
    }
}
