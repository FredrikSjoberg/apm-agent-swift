//
//  Logger.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

internal protocol Logger {
    func debug(_ message: Any)
    func info(_ message: Any)
    func error(_ message: Any)
    var logLevel: LogLevel { get set }
}
