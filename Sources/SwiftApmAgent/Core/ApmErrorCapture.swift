//
//  ApmErrorCapture.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-04.
//

import Foundation

internal class ApmErrorCapture: ErrorCapture, CustomStringConvertible {
    
    private weak var tracer: Tracer?
    private let idProvider: IdProvider
    private let timestampProvider: TimestampProvider
    
    var timestamp: Int64
    
    let traceContext: TraceContext
    var eventContext: EventContext
    
    let id: IdRepresentation
    
    init(tracer: Tracer,
         traceContext: TraceContext,
         eventContext: EventContext,
         timestampProvider: TimestampProvider,
         idProvider: IdProvider = ApmIdProvider()) {
        self.tracer = tracer
        self.traceContext = traceContext
        self.eventContext = eventContext
        self.idProvider = idProvider
        self.timestampProvider = timestampProvider
        self.timestamp = timestampProvider.epochNow
        self.id = idProvider.generate128BitId()
    }
    
    func report() {
        tracer?.reportError(self)
    }
    
    var description: String {
        let timestamp = "\(self.timestamp) ms"
        return """
            -+ ApmErrorCapture
             |   id: \(id.hexString)
             |   timestamp: \(timestamp)
             |      TraceContext:
             |         traceId: \(traceContext.traceId.hexString)
             |         transactionId: \(traceContext.transactionId.hexString)
             |         parentId: \(traceContext.parentId?.hexString ?? "nil")
             |         serviceName: \(traceContext.serviceName ?? "nil")
            """
    }
}
