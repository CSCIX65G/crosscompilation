import Foundation
import SmokeHTTP1
import SmokeOperationsHTTP1
import NIOHTTP1
import HeliumLogger
import LoggerAPI
import Shell

typealias SmokeHandlerSelector = StandardSmokeHTTP1HandlerSelector
typealias JSONDelegate = JSONPayloadHTTP1OperationDelegate
typealias HandlerSelector = StandardSmokeHTTP1HandlerSelector<ApplicationContext, JSONPayloadHTTP1OperationDelegate>

let logger = HeliumLogger()
Log.logger = logger

let clockTimer = DispatchSource.makeTimerSource()

let services = [
    (path: "/echo", method: HTTPMethod.POST, handler: EchoService.self.serviceHandler),
    (path: "/clock", method: HTTPMethod.POST, handler: ClockService.self.serviceHandler),
    (path: "/led", method: HTTPMethod.POST, handler: LEDService.self.serviceHandler)
]

func createHandlerSelector() -> HandlerSelector {
    var handlerSelector = HandlerSelector(
        defaultOperationDelegate: ApplicationContext.operationDelegate
    )
    services.forEach { service in
        handlerSelector.addHandlerForUri(service.path, httpMethod: service.method, handler: service.handler)
    }
    return handlerSelector
}

func startClockTimer() {
    clockTimer.setEventHandler {
        guard let display = ClockService.display else { return }
        if ClockService.clockState {
            display.show(ClockService.df.string(from:Date()))
        }
    }
    
    clockTimer.schedule(deadline  : .now(),
                   repeating : .seconds(1),
                   leeway    : .milliseconds(1))
    clockTimer.resume()
}

do {
    Log.info("Starting Server")
    Log.info("Verifying shell availability.  Hostname = \(shell.hostname())")
    
    // GPIO related startup
    startClockTimer()
    GPIOInput.handleButtons()
    
    let handlerSelector = createHandlerSelector()
    let server = try SmokeHTTP1Server.startAsOperationServer(
        withHandlerSelector: handlerSelector,
        andContext: ApplicationContext()
    )
    try server.waitUntilShutdownAndThen {
        Log.info("shutdown server = \(server)")
    }
    Log.info("started server = \(server)")
} catch {
    Log.error("Unable to start Operation Server: '\(error)'")
}
