//
//  File.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

public class ApmAgent {
    
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

