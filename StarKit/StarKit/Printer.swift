
import Foundation
import StarIO

public enum PrintingError: ErrorType {
    case PrintDataConversion
    case WritingData
    case EstablishingConnection
}

public protocol PrinterDelegate {
    func printer(printer: Printer, didChangeStatus newStatus: PrinterStatus)
}

public enum PrinterStatus: String {
    case Connected = "Connected"
    case Connecting = "Connecting"
    case Disconnected = "Disconnected"
}

typealias BooleanResultBlock = Bool -> Void

public class Printer {
    
    private var port: SMPort?
    private let portInfo: PortInfo
    
    public var delegate: PrinterDelegate?
    public var status: PrinterStatus {
        didSet {
            delegate?.printer(self, didChangeStatus: status)
        }
    }
    public var printing: Bool
    
    public var portName: String {
        return portInfo.portName
    }
    public var macAddress: String {
        return portInfo.macAddress
    }
    public var modelName: String {
        return portInfo.modelName
    }
    public var name: String {
        return "Model: \(modelName), MAC: \(macAddress)"
    }
    
    private let queue = NSOperationQueue()
    
    init(portInfo: PortInfo) {
        self.portInfo = portInfo
        self.status = .Disconnected
        self.printing = false
        self.queue.maxConcurrentOperationCount = 1
    }
    
    public static func searchForLANPrintersWithCompletionHandler(completion: [Printer] -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let found = SMPort.searchPrinter("TCP:") as! [PortInfo]
            
            let printers = found.map { portInfo in
                return Printer(portInfo: portInfo)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(printers)
            }
        }
    }
    
    public func printData(printData: PrintData, completionHandler completion: Void -> Void) {
        queue.addOperationWithBlock {
            do {
                let data = try printData.rawData()
                try self.sendData(data)
                completion()
            } catch {
                print(error)
            }
        }
    }

    private func sendData(data: NSData) throws {
        try establishConnection()
        
        printing = true
        
        let totalDataSize = data.length
        let dataSentToPrinter = malloc(totalDataSize)
        data.getBytes(dataSentToPrinter, length: data.length)
        
        var totalAmountWritten: UInt32 = 0
        while totalAmountWritten < UInt32(totalDataSize) {
            let amountRemaining = UInt32(totalDataSize) - totalAmountWritten
            let blockSize: UInt32 = amountRemaining > 1024 ? 1024 : amountRemaining
            totalAmountWritten = port?.writePort(UnsafePointer<UInt8>(dataSentToPrinter), totalAmountWritten, blockSize) ?? UInt32(totalDataSize + 1)
            
            if totalAmountWritten > UInt32(totalDataSize) {
                free(dataSentToPrinter)
                throw PrintingError.WritingData
            }
        }
        
        free(dataSentToPrinter)
        
        var token: dispatch_once_t = 0
        if queue.operationCount == 1 {
            printing = false
            closeConnection()
            token = 0
        } else {
            dispatch_once(&token) {
                dispatch_after(30, dispatch_get_main_queue()) {
                    if self.printing {
                        self.closeConnection()
                        token = 0
                    }
                }
            }
        }
    }

    private func establishConnection() throws {
        guard status == .Disconnected else {
            return
        }
        
        status = .Connecting
        var connected = false
        for _ in 0..<3 {
            connected = openPort()
            if connected {
                status = .Connected
                return
            }
            sleep(3)
        }
        
        status = .Disconnected
        throw PrintingError.EstablishingConnection
    }
    
    private func closeConnection() {
        releasePort()
        status = .Disconnected
    }
    
    private func openPort() -> Bool {
        port = SMPort.getPort(portName, "", 10000)
        return port != nil
    }
    
    private func releasePort() {
        if let _ = port {
            SMPort.releasePort(port)
            port = nil
        }
    }

}
