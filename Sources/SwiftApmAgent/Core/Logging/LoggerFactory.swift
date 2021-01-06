//
//  LoggerFactory.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

internal struct LoggerFactory {
    static let generalSubsystem = "General Subsystem"
    
    /// Actual `LogLevel` is determined by
    ///
    /// 1. Explicit `LogLevel` specified on logger creation
    /// 2. `LogLevelRegistry` definitions
    /// 3. If no level can be found, defaults to `.error`
    ///
    static func getLogger(_ object: AnyClass, _ requestedLevel: LogLevel? = nil) -> Logger {
        let actualLogLevel = logLevel(for: object, requestedLevel: requestedLevel)
        if #available(macOS 11, iOS 11, *) {
            return ApmOSLogger(subsystem: logSubsystem(for: object),
                               category: logCategory(for: object),
                               logLevel: actualLogLevel)
        } else {
            return ApmConsoleLogger(logLevel: actualLogLevel)
        }
    }
    
    private static func logCategory(for object: AnyClass) -> String {
        return String(describing: object)
    }
    
    private static func logSubsystem(for object: AnyClass) -> String {
        guard let identifier = Bundle(for: object).bundleIdentifier else {
            return generalSubsystem
        }
        return identifier
    }
    
    private static func logLevel(for object: AnyClass, requestedLevel: LogLevel?) -> LogLevel {
        if let requestedLevel = requestedLevel {
            return requestedLevel
        } else if let registeredLevel = LogLevelRegistry.shared.logLevel(object) {
            return registeredLevel
        } else {
            return .error
        }
    }
}
