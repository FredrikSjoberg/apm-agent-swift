//
//  File.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

public class ApmAgent: NSObject {
    
    public class func shared() -> ApmAgent {
        return sharedInstance
    }
    private static let sharedInstance = ApmAgent()
    
    override private init() {
        tracer = ApmTracer()
        
        super.init()
    }
    
    var tracer: Tracer
    
    public func register(_ plugins: [Plugin]) {
        plugins.forEach { plugin in
            plugin.configure()
            (tracer as? ApmTracer)?.register(intakeEncoders: plugin.intakeEncoders)
        }
    }
}

