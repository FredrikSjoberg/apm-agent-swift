//
//  ApmURLSessionSpanEncoder.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

internal class ApmURLSessionSpanEncoder: IntakeEncoder {
    
    private static let http = "HTTP"
    private static let success = "success"
    private static let failure = "failure"
    
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }
    
    func encode(_ span: Span) throws -> Data {
        guard let context = span.spanContext as? ApmURLSessionSpanContext else {
            throw ApmEncodingError.unsupportedSpanContext(span)
        }
        
        if let transaction = span as? Transaction {
            let event = transactionEvent(transaction: transaction, context: context)
            return try jsonEncoder.encode(event)
        } else {
            let event = spanEvent(span: span, context: context)
            return try jsonEncoder.encode(event)
        }
    }
    
    // MARK: Transaction Event
    private func transactionEvent(transaction: Transaction, context: ApmURLSessionSpanContext) -> TransactionEvent {
        let event = TransactionEvent.Transaction(timestamp: transaction.timestamp,
                                                 type: transaction.type,
                                                 name: transaction.name,
                                                 id: transaction.id,
                                                 traceId: transaction.traceContext.traceId,
                                                 parentId: transaction.traceContext.parentId,
                                                 spanCount: spanCount(),
                                                 duration: transaction.duration,
                                                 result: result(context),
                                                 outcome: outcome(context),
                                                 sampled: true,
                                                 context: transactionContext(context))
        return .init(transaction: event)
    }
    
    private func spanCount() -> TransactionEvent.Transaction.SpanCount {
        return .init(started: 0, dropped: nil)
    }
    
    private func result(_ context: ApmURLSessionSpanContext) -> String? {
        guard let statusCode = context.statusCode else {
            return nil
        }
        return ApmURLSessionSpanEncoder.http + " \(statusCode)"
    }
    
    private func outcome(_ context: ApmURLSessionSpanContext) -> String? {
        guard let statusCode = context.statusCode else {
            return nil
        }
        if statusCode >= 400 {
            return ApmURLSessionSpanEncoder.failure
        } else {
            return ApmURLSessionSpanEncoder.success
        }
    }
    
    private func transactionContext(_ context: ApmURLSessionSpanContext) -> TransactionEvent.Transaction.Context? {
        return .init(response: transactionResponse(context),
                     request: transactionRequest(context))
    }
    
    private func transactionRequest(_ context: ApmURLSessionSpanContext) -> TransactionEvent.Transaction.Context.Request? {
        return .init(body: nil,
                     env: [:],
                     headers: [:],
                     httpVersion: nil,
                     method: context.method,
                     url: transactionUrl(context))
    }
    
    private func transactionResponse(_ context: ApmURLSessionSpanContext) -> TransactionEvent.Transaction.Context.Response? {
        return .init(statusCode: context.statusCode,
                     transferSize: nil,
                     encodedBodySize: nil,
                     decodedBodySize: nil,
                     headers: [:],
                     finished: context.finished)
    }
    
    private func transactionUrl(_ context: ApmURLSessionSpanContext) -> TransactionEvent.Transaction.Context.Request.URL {
        return .init(raw: context.url.absoluteString,
                     protocol: context.url.scheme,
                     full: context.url.absoluteString,
                     hostname: context.url.host,
                     port: context.url.port,
                     pathname: context.url.path,
                     search: nil,
                     cookies: [:])
    }
    
    // MARK: Span Event
    private func spanEvent(span: Span, context: ApmURLSessionSpanContext) -> SpanEvent {
        let event = SpanEvent.Span(timestamp: span.timestamp,
                                   type: span.type,
                                   subtype: span.subtype,
                                   id: span.id,
                                   transactionId: span.traceContext.transactionId,
                                   traceId: span.traceContext.traceId,
                                   parentId: span.traceContext.parentId ?? span.traceContext.transactionId,
                                   childIds: [],
                                   start: span.timestamp / ApmTimestampProvider.milliSeconds,
                                   action: nil,
                                   outcome: outcome(context),
                                   context: spanContext(context),
                                   duration: span.duration,
                                   name: span.name)
        return .init(span: event)
    }
    
    private func spanContext(_ context: ApmURLSessionSpanContext) -> SpanEvent.Span.Context? {
        return .init(destination: destination(context),
                     db: nil,
                     http: http(context),
                     service: nil)
    }
    
    private func destination(_ context: ApmURLSessionSpanContext) -> SpanEvent.Span.Context.Destination? {
        let address = context.destination?.address
        let port = context.destination?.port
        let service = destinationService(context)
        guard address != nil || port != nil || service != nil else {
            return nil
        }
        
        return .init(address: context.destination?.address,
                     port: context.destination?.port,
                     service: destinationService(context))
    }
    
    private func destinationService(_ context: ApmURLSessionSpanContext) -> SpanEvent.Span.Context.Destination.Service? {
        guard let type = context.destination?.service?.type,
              let name = context.destination?.service?.name,
              let resource = context.destination?.service?.name else {
            return nil
        }
        return .init(type: type,
                     name: name,
                     resource: resource)
    }
    
    private func http(_ context: ApmURLSessionSpanContext) -> SpanEvent.Span.Context.Http {
        return .init(url: context.url.absoluteString,
                     method: context.method,
                     response: httpResponse(context))
    }
    
    private func httpResponse(_ context: ApmURLSessionSpanContext) -> SpanEvent.Span.Context.Http.Response {
        
        return .init(statusCode: context.statusCode,
                     transferSize: nil,
                     encodedBodySize: nil,
                     decodedBodySize: nil,
                     headers: [:])
    }
}
