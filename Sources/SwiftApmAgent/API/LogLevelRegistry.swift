//
//  LogLevelRegistry.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

public protocol LogLevelRegistry {
    func logLevel(_ level: LogLevel, for logIdentifier: String)
    func logLevel(_ level: LogLevel, for type: AnyClass)
    func logLevel(_ type: AnyClass) -> LogLevel?
    func logLevel(_ logIdentifier: String) -> LogLevel?
}
