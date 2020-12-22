//
//  ApmSpanEncoder.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmSpanEncoder: IntakeEncoder {
    enum Error: Swift.Error {
        case unsupportedSpanContext(Span)
        case unsupportedEventType(Span)
    }
    
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }
    
    func encode(_ span: Span) throws -> Data {
        if let transaction = span as? Transaction {
            throw ApmEncodingError.unsupportedEventType(transaction)
        }
        guard let context = span.spanContext as? ApmSpanContext else {
            throw ApmEncodingError.unsupportedSpanContext(span)
        }
        let event = spanEvent(span: span, context: context)
        return try jsonEncoder.encode(event)
    }
    
    private func spanEvent(span: Span, context: ApmSpanContext) -> SpanEvent {
        let event = SpanEvent.Span(timestamp: span.timestamp,
                                   type: span.type,
                                   subtype: span.subtype,
                                   id: span.id.hexString,
                                   transactionId: span.traceContext.transactionId.hexString,
                                   traceId: span.traceContext.traceId.hexString,
                                   parentId: span.traceContext.parentId?.hexString ?? span.traceContext.transactionId.hexString,
                                   childIds: [],
                                   start: span.timestamp / ApmTimestampProvider.milliSeconds,
                                   action: nil,
                                   outcome: nil,
                                   context: nil,
                                   duration: span.duration,
                                   name: span.name)
        return .init(span: event)
    }
}
