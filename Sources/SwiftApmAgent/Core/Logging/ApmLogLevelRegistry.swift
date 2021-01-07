//
//  LogLevel.swift
//
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

internal class ApmLogLevelRegistry: LogLevelRegistry {
    internal enum Error: Swift.Error {
        case bundleIdentifierNotFound(AnyClass)
    }
    
    private lazy var registry: [String: LogLevel] = {
        var result: [String: LogLevel] = [:]
        if let identifier = try? typeIdentifier(for: ApmHttpClient.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmEventDispatcher.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmEventQueue.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmReporter.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmTracer.self) {
            result[identifier] = .info
        }
        return result
    }()
    
    internal func logLevel(_ level: LogLevel, for logIdentifier: String) {
        registry[logIdentifier] = level
    }
    
    internal func logLevel(_ level: LogLevel, for type: AnyClass) {
        guard let logIdentifier = try? typeIdentifier(for: type) else {
            return
        }
        logLevel(level, for: logIdentifier)
    }
    
    internal func logLevel(_ type: AnyClass) -> LogLevel? {
        guard let logIdentifier = try? typeIdentifier(for: type) else {
            return nil
        }
        return logLevel(logIdentifier)
    }
    
    internal func logLevel(_ logIdentifier: String) -> LogLevel? {
        return registry[logIdentifier]
    }
    
    private func typeIdentifier(for type: AnyClass) throws -> String? {
        let typeId = String(describing: type)
        guard let bundleIdentifier = Bundle(for: type).bundleIdentifier else {
            throw ApmLogLevelRegistry.Error.bundleIdentifierNotFound(type)
        }
        return "\(bundleIdentifier).\(typeId)"
    }
}
