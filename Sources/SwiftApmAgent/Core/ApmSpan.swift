//
//  ApmSpan.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//


import Foundation

internal class ApmSpan: Span, CustomStringConvertible {
    
    static let durationNotSetConstant: Int64 = -1
    
    private weak var tracer: Tracer?
    private let idProvider: IdProvider
    private let timestampProvider: TimestampProvider
    
    init(name: String,
         type: String,
         tracer: Tracer,
         traceContext: TraceContext,
         timestampProvider: TimestampProvider,
         spanContext: EventContext = ApmSpanContext(),
         idProvider: IdProvider = ApmIdProvider()) {
        self.tracer = tracer
        self.traceContext = traceContext
        self.eventContext = spanContext
        self.idProvider = idProvider
        self.timestampProvider = timestampProvider
        self.timestamp = timestampProvider.epochNow
        self.id = idProvider.generate64BitId()
        self.name = name
        self.type = type
        self.duration = ApmSpan.durationNotSetConstant
    }
    
    // MARK: <Event>
    var timestamp: Int64
    
    let traceContext: TraceContext
    var eventContext: EventContext
    
    let id: IdRepresentation
    
    // MARK: <Span>
    var name: String
    var type: String
    var subtype: String?
    
    var duration: Int64
    
    var finished: Bool = false
    
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
    
    func activate() {
        tracer?.activate(self)
    }
    
    func deactivate() {
        tracer?.deactivate(self)
    }
    
    func end() {
        duration = (timestampProvider.epochNow - timestamp) / ApmTimestampProvider.milliSeconds
        finished = true
        tracer?.endSpan(self)
    }
    
    // MARK: <CustomStringConvertible>
    var description: String {
        let timestamp = "\(self.timestamp) ms"
        let duration = self.duration != ApmSpan.durationNotSetConstant ? "\(self.duration) ms" : "n/a"
        return """
            -+ ApmSpan
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
