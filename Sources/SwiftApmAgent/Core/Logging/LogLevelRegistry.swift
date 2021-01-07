//
//  LogLevelRegistry.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

internal class LogLevelRegistry {
    
    enum Error: Swift.Error {
        case bundleIdentifierNotFound(AnyClass)
    }
    
    static let shared = LogLevelRegistry()
    
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
        if let identifier = try? typeIdentifier(for: ScreenStack.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmTracer.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmURLSessionPlugin.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmViewControllerPlugin.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmUserSessionPlugin.self) {
            result[identifier] = .info
        }
        if let identifier = try? typeIdentifier(for: ApmSystemMetricSetPlugin.self) {
            result[identifier] = .info
        }
        return result
    }()
    
    func logLevel(_ level: LogLevel, for logIdentifier: String) {
        registry[logIdentifier] = level
    }
    
    func logLevel(_ level: LogLevel, for type: AnyClass) {
        guard let logIdentifier = try? typeIdentifier(for: type) else {
            return
        }
        logLevel(level, for: logIdentifier)
    }
    
    func logLevel(_ type: AnyClass) -> LogLevel? {
        guard let logIdentifier = try? typeIdentifier(for: type) else {
            return nil
        }
        return logLevel(logIdentifier)
    }
    
    func logLevel(_ logIdentifier: String) -> LogLevel? {
        return registry[logIdentifier]
    }
    
    private func typeIdentifier(for type: AnyClass) throws -> String? {
        let typeId = String(describing: type)
        guard let bundleIdentifier = Bundle(for: type).bundleIdentifier else {
            throw LogLevelRegistry.Error.bundleIdentifierNotFound(type)
        }
        return "\(bundleIdentifier).\(typeId)"
    }
}
