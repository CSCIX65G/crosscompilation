//
//  ClockService.swift
//  Server
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

struct ClockService: Service {
    typealias InputType = ClockInput
    typealias OutputType = ClockOutput
    
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    static let shield  = LKRBShield.default
    static let smallShield  = LKRBShield.default
    static var timer: Timer?
    
    static let display:LKDigi? = {
        guard let shield = shield else { return nil }
        let d = LKDigi()
        shield.connect(d, to: .digital45)
        return d
    }()

    static let df: DateFormatter = {
        let d = DateFormatter()
        d.dateFormat = "mmss"
        return d
    }()

    // decode the input stream from the request
    static let inputDecoder = { (request: SmokeHTTP1RequestHead, data: Data?) throws -> ClockInput in
        Log.info("Handling ClockService request: \(request)")
        guard let data = data, let decoded = ClockInput(data: data) else {
            Log.error("No request body for request \(request)")
            throw ApplicationContext.allowedErrors[0].0
        }
        return decoded
    }
    
    // transform the input into the output
    typealias ClockResultHandler = (SmokeResult<ClockOutput>) -> Void
    static let transform = { (input: ClockInput, context: ApplicationContext) -> ClockOutput in
        let output = ClockOutput(clockState: input.clockState)
        Log.info("Transforming ClockService Input: \(input)")
        guard let shield = shield, let display = display else {
            Log.info("Shield or Display note available.  Completing transform")
            return ClockOutput(clockState: "off")
        }
        if input.isOn {
            display.show(9999)
            OperationQueue.main.addOperation {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                    display.show(df.string(from:Date()))
                }
            }
        } else {
            display.turnOff()
            timer?.invalidate()
            timer = nil
        }
        Log.info("Finished Transforming ClockService Input: \(input) to Output: \(output)")
        return output
    }
    
    // encode the output into the response
    static let outputEncoder = { (request: SmokeHTTP1RequestHead, output: ClockOutput, responseHandler: HTTP1ResponseHandler) in
        var body = ( contentType: "application/json", data: Data() )
        var responseCode = HTTPResponseStatus.ok
        if let encoded = output.clockState.data(using: .utf8)  {
            body = ( contentType: "application/json", data: encoded )
        } else {
            responseCode = HTTPResponseStatus.internalServerError
            body = ( contentType: "application/json", data: try! jsonEncoder.encode(["message": "output failure"]) )
        }
        let response = HTTP1ServerResponseComponents(
            additionalHeaders: [],
            body: body
        )
        Log.info("Encoding ClockService Output: \(response)")
        responseHandler.completeInEventLoop(status: responseCode, responseComponents: response)
    }
    
    static let serviceHandler = OperationHandler<ApplicationContext, SmokeHTTP1RequestHead, HTTP1ResponseHandler>(
        inputProvider: ClockService.inputDecoder,
        operation: ClockService.transform,
        outputHandler: ClockService.outputEncoder,
        allowedErrors: ApplicationContext.allowedErrors,
        operationDelegate: ApplicationContext.operationDelegate
    )
}
