//
//  ApmAgent.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

public class ApmAgent {
    #warning("APM-TODO: Use correct Agent Version")
    public let agentName: String = "SwiftApmAgent"
    public let agentVersion: String = "1.0.0"
    
    /// In seconds
    public let defaultDispatchFrequency: Int = 30
    
    public class func shared() -> ApmAgent {
        return sharedInstance
    }
    private static let sharedInstance = ApmAgent()
    
    private init() { }
    
    public internal(set) lazy var tracer: Tracer = {
        let eventQueue = ApmEventQueue(dispatchFrequency: serverConfiguration?.dispatchFrequency ?? defaultDispatchFrequency)
        let reporter = ApmReporter(eventQueue: eventQueue)
        return ApmTracer(reporter: reporter)
    }()
    public internal(set) var serverConfiguration: ApmServerConfiguration?
    public internal(set) var plugins: [Plugin] = []
    public let logLevelRegistry: LogLevelRegistry = ApmLogLevelRegistry()
    
    public func configure(_ serverConfiguration: ApmServerConfiguration) {
        self.serverConfiguration = serverConfiguration
    }
    
    public func register(_ plugins: [Plugin]) {
        plugins.forEach { plugin in
            plugin.configure()
            (tracer as? ApmTracer)?.register(intakeEncoders: plugin.intakeEncoders)
        }
        self.plugins = plugins
    }
    
    internal func plugin<T>(_ type: T.Type) -> T? where T: Plugin {
        return plugins.compactMap {
            $0 as? T
        }
        .first
    }
}

