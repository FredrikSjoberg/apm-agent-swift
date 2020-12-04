//
//  ApmOSLogger.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation
import os

@available(macOS 11, iOS 11, *)
internal struct ApmOSLogger: Logger {
    
    private var logger: OSLog
    
    init(subsystem: String, category: String, logLevel: LogLevel = .info) {
        self.logger = OSLog(subsystem: subsystem, category: category)
        self.logLevel = logLevel
    }
    
    // MARK: <Logger>
    func debug(_ message: Any) {
        log(.debug, message)
    }
    
    func info(_ message: Any) {
        log(.info, message)
    }
    
    func error(_ message: Any) {
        log(.error, message)
    }
    
    var logLevel: LogLevel
    
    // MARK: <Private>
    private func log(_ level: LogLevel, _ item: Any) {
        guard level.rawValue >= logLevel.rawValue else {
            return
        }
        
        let message = logMessage(item)
        
        os_log("%@", log: logger, type: osLogType(level), "\(message)")
    }
    
    private func osLogType(_ level: LogLevel) -> OSLogType {
        switch level {
        case .debug: return .debug
        case .info: return .info
        case .error: return .error
        @unknown default: return .default
        }
    }
    
    private func logMessage(_ item: Any) -> String {
        if let item = item as? String {
            return item
        } else if let item = item as? CustomStringConvertible {
            return "\(item)"
        } else if let item = item as? CustomDebugStringConvertible {
            return "\(item)"
        } else if let item = item as? NSObjectProtocol {
            return item.description
        } else {
            return ""
        }
    }
}
