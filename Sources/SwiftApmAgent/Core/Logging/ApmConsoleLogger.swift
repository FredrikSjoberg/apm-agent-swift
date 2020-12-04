//
//  ApmConsoleLogger.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

internal struct ApmConsoleLogger: Logger {
    
    init(logLevel: LogLevel = .info) {
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
    
    var logLevel: LogLevel = .info
    
    // MARK: <Private>
    private func log(_ level: LogLevel, _ message: Any) {
        guard level.rawValue >= logLevel.rawValue else {
            return
        }
        print("\(levelDescription(level)) : \(message)")
    }
    
    private func levelDescription(_ level: LogLevel) -> String {
        switch level {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .error: return "ERROR"
        @unknown default: return "UNKNOWN"
        }
    }
}
