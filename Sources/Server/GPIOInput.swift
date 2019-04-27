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
    static let pot = LKTemp(interval: 0.2, valueType: .voltage)
    static var potValue = 0

    static func handleButtons() {
        guard let shield  = LKRBShield.default else { return }
        Log.logger = logger

        // Button
        shield.connect(button, to: .digital2627)
        button.onPress1 {
            Log.info("Button 1 was pressed!")
            LEDService.led.on = !LEDService.led.on
        }
        button.onChange1 { isPressed in
            Log.info("Button 1 changed, it is now: \(isPressed ? "pressed" : "off" )")
        }

        // Touch Sensor
        shield.connect(touchSensor, to: .digital2122)
        touchSensor.onPress1 {
            Log.info("Sensor was touched!")
        }
        touchSensor.onChange1 { isPressed in
            Log.info("Sensor changed, it is now: \(isPressed ? "touched" : "off" )")
            LEDService.led.on = !LEDService.led.on
        }
        
        // Potentiometer
        shield.connect(pot, to: .analog45)
        pot.onChange { (newValue) in
            let newIntValue = Int(newValue * 100.0)
            if newIntValue != self.potValue {
                self.potValue = newIntValue
                Log.info("Potentiometer changed, it is now: \(newValue)")
                ClockService.display?.show(Int(newValue*100))
            }
        }
    }
}
