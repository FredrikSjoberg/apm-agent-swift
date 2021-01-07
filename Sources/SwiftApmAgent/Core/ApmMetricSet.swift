//
//  File.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

internal class ApmMetricSet: MetricSet, CustomStringConvertible {
    
    private weak var tracer: Tracer?
    private let idProvider: IdProvider
    private let timestampProvider: TimestampProvider
    
    init(tracer: Tracer,
         traceContext: TraceContext,
         eventContext: EventContext = ApmMetricSetContext(),
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
    
    // MARK: <Event>
    var timestamp: Int64
    
    let traceContext: TraceContext
    var eventContext: EventContext
    
    let id: IdRepresentation
    
    // MARK: <Metricset>
    func report() {
        tracer?.reportMetricSet(self)
    }
    
    // MARK: <CustomStringConvertible>
    var description: String {
        let timestamp = "\(self.timestamp) ms"
        return """
            -+ ApmMetricSet
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
