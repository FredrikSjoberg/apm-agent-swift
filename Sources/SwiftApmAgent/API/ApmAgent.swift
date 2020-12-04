//
//  File.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

@objc
public class ApmAgent: NSObject {
    @objc
    class func shared() -> ApmAgent {
        return sharedInstance
    }
    private static let sharedInstance = ApmAgent()
    
    override private init() {
        tracer = ApmTracer()
        
        super.init()
    }
    
    @objc var tracer: Tracer
}
