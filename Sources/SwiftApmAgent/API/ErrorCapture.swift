//
//  ErrorCapture.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-04.
//

import Foundation

public protocol ErrorCapture: Event {
    /// Recorded time of the event, UTC based and formatted as microseconds since Unix epoch
    var timestamp: Int64 { get }
    
    var traceContext: TraceContext { get }
    var eventContext: EventContext { get set }
    
    var id: IdRepresentation { get }
    
    func report()
}
