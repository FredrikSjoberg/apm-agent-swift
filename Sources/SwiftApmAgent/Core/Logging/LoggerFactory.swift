//
//  File.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

internal struct LoggerFactory {
    static func getLogger(_ object: AnyClass, _ logLevel: LogLevel) -> Logger {
        guard let identifier = Bundle(for: object).bundleIdentifier else {
            fatalError("LoggerFactory: Unable to determine logger for object, \(object.description())")
        }
        let description = String(describing: object)
        if #available(macOS 11, iOS 11, *) {
            return ApmOSLogger(subsystem: identifier, category: description, logLevel: logLevel)
        } else {
            return ApmConsoleLogger(logLevel: logLevel)
        }
    }
}
