//
//  ApmCoreDataSpanEncoder.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-22.
//


import Foundation

internal class ApmCoreDataSpanEncoder: IntakeEncoder {
    
    private static let action = "query"
    private static let success = "success"
    private static let failure = "failure"
    
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }
    
    func encode(_ span: Span) throws -> Data {
        guard let context = span.spanContext as? ApmCoreDataSpanContext else {
            throw ApmEncodingError.unsupportedSpanContext(span)
        }
        
        let event = spanEvent(span: span, context: context)
        return try jsonEncoder.encode(event)
    }
    
    private func outcome(_ context: ApmCoreDataSpanContext) -> String? {
        return context.outcome
    }
    
    // MARK: Span Event
    private func spanEvent(span: Span, context: ApmCoreDataSpanContext) -> SpanEvent {
        let event = SpanEvent.Span(timestamp: span.timestamp,
                                   type: span.type,
                                   subtype: span.subtype,
                                   id: span.id.hexString,
                                   transactionId: span.traceContext.transactionId.hexString,
                                   traceId: span.traceContext.traceId.hexString,
                                   parentId: span.traceContext.parentId?.hexString ?? span.traceContext.transactionId.hexString,
                                   childIds: [],
                                   start: span.timestamp / ApmTimestampProvider.milliSeconds,
                                   action: ApmCoreDataSpanEncoder.action,
                                   outcome: outcome(context),
                                   context: spanContext(context),
                                   duration: span.duration,
                                   name: span.name)
        return .init(span: event)
    }
    
    private func spanContext(_ context: ApmCoreDataSpanContext) -> SpanEvent.Span.Context? {
        return .init(destination: nil,
                     db: db(context),
                     http: nil,
                     service: nil)
    }
    
    private func db(_ context: ApmCoreDataSpanContext) -> SpanEvent.Span.Context.Db {
        return .init(instance: context.name,
                     link: nil,
                     statement: context.statement,
                     type: context.dbType,
                     user: nil,
                     rowsAffected: context.rowsAffected)
    }
}
