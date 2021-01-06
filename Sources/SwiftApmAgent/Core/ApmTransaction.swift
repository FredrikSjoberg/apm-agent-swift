//
//  ApmTransaction.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmTransaction: Transaction, CustomStringConvertible {
    
    private weak var tracer: Tracer?
    private let idProvider: IdProvider
    private let timestampProvider: TimestampProvider
    
    var timestamp: Int64
    var duration: Int64
    
    init(name: String,
         type: String,
         tracer: Tracer,
         traceContext: TraceContext,
         timestampProvider: TimestampProvider,
         spanContext: EventContext = ApmTransactionContext(),
         idProvider: IdProvider = ApmIdProvider()) {
        self.tracer = tracer
        self.traceContext = traceContext
        self.eventContext = spanContext
        self.idProvider = idProvider
        self.timestampProvider = timestampProvider
        self.id = traceContext.transactionId
        self.timestamp = timestampProvider.epochNow
        self.name = name
        self.type = type
        self.duration = ApmSpan.durationNotSetConstant
    }
    
    // MARK: <Span>
    var name: String
    var type: String
    var subtype: String?
    
    let traceContext: TraceContext
    var eventContext: EventContext
    
    let id: IdRepresentation
    
    var finished: Bool = false
    
    func end() {
        duration = (timestampProvider.epochNow - timestamp) / ApmTimestampProvider.milliSeconds
        finished = true
        tracer?.endTransaction(self)
    }
    
    func activate() {
        tracer?.activate(self)
    }
    
    func deactivate() {
        tracer?.deactivate(self)
    }
    
    func createSpan(name: String, type: String) -> Span? {
        guard let tracer = tracer else {
            #warning("APM-TODO: Code duplication + returning nil")
            return nil
        }
        let context = traceContext.createChild(parentId: id)
        let span = ApmSpan(name: name,
                           type: type,
                           tracer: tracer,
                           traceContext: context,
                           timestampProvider: timestampProvider)
        return span
    }
    
    func captureError(_ error: Error) -> ErrorCapture? {
        guard let tracer = tracer else {
            return nil
        }
        let context = traceContext.createChild(parentId: id)
        let errorCapture = ApmErrorCapture(tracer: tracer,
                                           traceContext: context,
                                           eventContext: ApmErrorCaptureContext(error: error),
                                           timestampProvider: timestampProvider,
                                           idProvider: idProvider)
        return errorCapture
    }
    
    // MARK: <CustomStringConvertible>
    var description: String {
        let timestamp = "\(self.timestamp) ms"
        let duration = self.duration != ApmSpan.durationNotSetConstant ? "\(self.duration) ms" : "n/a"
        return """
            -+ ApmTransaction
             |   id: \(id.hexString)
             |   name: \(name)
             |   type: \(type)
             |   subtype: \(subtype ?? "nil")
             |   timestamp: \(timestamp)
             |   duration: \(duration)
             |   finished: \(finished)
             |      TraceContext:
             |         traceId: \(traceContext.traceId.hexString)
             |         transactionId: \(traceContext.transactionId.hexString)
             |         parentId: \(traceContext.parentId?.hexString ?? "nil")
             |         serviceName: \(traceContext.serviceName ?? "nil")
            """
    }
}
