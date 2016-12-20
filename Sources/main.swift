import HeliumLogger
import Foundation
import Kitura
import LoggerAPI
import SwiftyJSON

HeliumLogger.use(LoggerMessageType.info)
let controller = Controller()
Log.info("Server will be started on .")
Kitura.addHTTPServer(onPort: controller.port, with: controller.router)
Kitura.run()
