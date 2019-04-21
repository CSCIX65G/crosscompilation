//
//  LEDService.swift
//  Bluetooth
//
//  Created by Van Simmons on 4/21/19.
//

import Foundation
import SmokeHTTP1
import SmokeOperations
import SmokeOperationsHTTP1
import LoggerAPI
import NIOHTTP1
import Dispatch
import SwiftyLinkerKit

struct LEDService: Service {
    typealias InputType = LEDInput
    typealias OutputType = LEDOutput
    
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    static let shield  = LKRBShield.default
    static let smallShield  = LKRBShield.default
    static var ledState: Bool = false {
        didSet {
            led.on = ledState
        }
    }
    
    static let led:LKLed = {
        let l = LKLed()
        guard let shield = shield else { return l }
        shield.connect(l, to: .digital1516)
        return l
    }()
    
    static let df: DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "mmss"
        return d
    }()
    
    // decode the input stream from the request
    static let inputDecoder = { (request: SmokeHTTP1RequestHead, data: Data?) throws -> LEDInput in
        Log.info("Handling LEDService request: \(request)")
        guard let data = data, let decoded = LEDInput(data: data) else {
            Log.error("No request body for request \(request)")
            throw ApplicationContext.allowedErrors[0].0
        }
        return decoded
    }
    
    // transform the input into the output
    typealias LEDResultHandler = (SmokeResult<LEDOutput>) -> Void
    static let transform = { (input: LEDInput, context: ApplicationContext) -> LEDOutput in
        let output = LEDOutput(ledState: input.ledState)
        Log.info("Transforming LEDService Input: \(input)")
        guard let shield = shield else {
            Log.info("Shield or Display note available.  Completing transform")
            return LEDOutput(ledState: "off")
        }
        led.on = input.isOn
        Log.info("Finished Transforming LEDService Input: \(input) to Output: \(output)")
        return output
    }
    
    // encode the output into the response
    static let outputEncoder = { (request: SmokeHTTP1RequestHead, output: LEDOutput, responseHandler: HTTP1ResponseHandler) in
        var body = ( contentType: "application/json", data: Data() )
        var responseCode = HTTPResponseStatus.ok
        if let encoded = output.ledState.data(using: .utf8)  {
            body = ( contentType: "application/json", data: encoded )
        } else {
            responseCode = HTTPResponseStatus.internalServerError
            body = ( contentType: "application/json", data: try! jsonEncoder.encode(["message": "output failure"]) )
        }
        let response = HTTP1ServerResponseComponents(
            additionalHeaders: [],
            body: body
        )
        Log.info("Encoding LEDService Output: \(response)")
        responseHandler.completeInEventLoop(status: responseCode, responseComponents: response)
    }
    
    static let serviceHandler = OperationHandler<ApplicationContext, SmokeHTTP1RequestHead, HTTP1ResponseHandler>(
        inputProvider: LEDService.inputDecoder,
        operation: LEDService.transform,
        outputHandler: LEDService.outputEncoder,
        allowedErrors: ApplicationContext.allowedErrors,
        operationDelegate: ApplicationContext.operationDelegate
    )
}
