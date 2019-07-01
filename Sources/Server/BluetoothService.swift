//
//  BluetoothService.swift
//  Bluetooth
//
//  Created by Van Simmons on 4/29/19.
//

import Foundation
import SmokeHTTP1
import SmokeOperations
import SmokeOperationsHTTP1
import LoggerAPI
import NIOHTTP1
import Dispatch
import SwiftyLinkerKit
import Foundation
import CoreFoundation
import Bluetooth

#if os(Linux)
import GATT
import BluetoothLinux
public typealias PeripheralManager = GATTPeripheral<HostController, L2CAPSocket>
#endif

public enum CommandError: Error {
    case bluetoothUnavailible
    case noCommand
    case invalidCommandType(String)
    case invalidOption(String)
    case missingOption(String)
    case optionMissingValue(String)
    case invalidOptionValue(option: String, value: String)
}

public protocol GATTServiceController: class {
    static var service: BluetoothUUID { get }
    var peripheral: PeripheralManager { get }
    init(peripheral: PeripheralManager) throws
}

internal let serviceControllers: [GATTServiceController.Type] = [
    GATTCustomServiceController.self
]

struct BluetoothService: Service {
    typealias InputType = BluetoothInput
    typealias OutputType = BluetoothOutput
    
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    
    static var bluetoothState: Bool = false
    
    // decode the input stream from the request
    static let inputDecoder = { (request: SmokeHTTP1RequestHead, data: Data?) throws -> BluetoothInput in
        Log.info("Handling BluetoothService request: \(request)")
        guard let data = data, let decoded = BluetoothInput(data: data) else {
            Log.error("No request body for request \(request)")
            throw ApplicationContext.allowedErrors[0].0
        }
        return decoded
    }
    
    // transform the input into the output
    typealias BluetoothResultHandler = (SmokeResult<BluetoothOutput>) -> Void
    static let transform = { (input: BluetoothInput, context: ApplicationContext) -> BluetoothOutput in
        let output = BluetoothOutput(bluetoothState: input.bluetoothState)
        Log.info("Transforming BluetoothService Input: \(input)")
        if input.isOn {
            bluetoothState = true
        } else {
            bluetoothState = false
        }
        Log.info("Finished Transforming BluetoothService Input: \(input) to Output: \(output)")
        return output
    }
    
    // encode the output into the response
    static let outputEncoder = { (request: SmokeHTTP1RequestHead, output: BluetoothOutput, responseHandler: HTTP1ResponseHandler) in
        var body = ( contentType: "application/json", data: Data() )
        var responseCode = HTTPResponseStatus.ok
        if let encoded = output.bluetoothState.data(using: .utf8)  {
            body = ( contentType: "application/json", data: encoded )
        } else {
            responseCode = HTTPResponseStatus.internalServerError
            body = ( contentType: "application/json", data: try! jsonEncoder.encode(["message": "output failure"]) )
        }
        let response = HTTP1ServerResponseComponents(
            additionalHeaders: [],
            body: body
        )
        Log.info("Encoding BluetoothService Output: \(response)")
        responseHandler.completeInEventLoop(status: responseCode, responseComponents: response)
    }
    
    static let serviceHandler = OperationHandler<ApplicationContext, SmokeHTTP1RequestHead, HTTP1ResponseHandler>(
        inputProvider: BluetoothService.inputDecoder,
        operation: BluetoothService.transform,
        outputHandler: BluetoothService.outputEncoder,
        allowedErrors: ApplicationContext.allowedErrors,
        operationDelegate: ApplicationContext.operationDelegate
    )

    static func stop() throws {
    }
    
    static func run(arguments: [String] = CommandLine.arguments) throws {
        #if os(Linux)
        //  first argument is always the current directory
        let arguments = Array(arguments.dropFirst())
        
        guard let controller = HostController.default
            else { throw CommandError.bluetoothUnavailible }
        
        print("Bluetooth Controller: \(controller.address)")
        
        let peripheral = PeripheralManager(controller: controller)
        peripheral.removeAllServices()
        peripheral.newConnection = { [weak peripheral] () throws -> (L2CAPSocket, Central) in
            let serverSocket = try L2CAPSocket.lowEnergyServer(
                controllerAddress: controller.address,
                isRandom: false,
                securityLevel: .low
            )
            let socket = try serverSocket.waitForConnection()
            let central = Central(identifier: socket.address)
            peripheral?.log?("[\(central)]: New \(socket.addressType) connection")
            return (socket, central)
        }
        
        peripheral.log = { print("PeripheralManager:", $0) }
        
        guard let serviceUUIDString = arguments.first
            else { throw CommandError.noCommand }
        
        guard let service = BluetoothUUID(rawValue: serviceUUIDString),
            let _ = serviceControllers.first(where: { $0.service == service })
            else { throw CommandError.invalidCommandType(serviceUUIDString) }
        
        serviceControllers.forEach { controllerType in
            _ = try? controllerType.init(peripheral: peripheral)
        }
        
        while true {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.001, true)
        }
        #endif
    }
}
