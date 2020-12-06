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
    
    public class func shared() -> ApmAgent {
        return sharedInstance
    }
    private static let sharedInstance = ApmAgent()
    
    private init() {
        tracer = ApmTracer()
    }
    
    internal var tracer: Tracer
    internal var serverConfiguration: ApmServerConfiguration?
    
    public func configure(_ serverConfiguration: ApmServerConfiguration) {
        self.serverConfiguration = serverConfiguration
    }
    
    public func register(_ plugins: [Plugin]) {
        plugins.forEach { plugin in
            plugin.configure()
            (tracer as? ApmTracer)?.register(intakeEncoders: plugin.intakeEncoders)
        }
    }
}

