//
//  ApmTransactionEncoder.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmTransactionEncoder: IntakeEncoder {
    
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }
    
    func encode(_ span: Span) throws -> Data {
        guard let transaction = span as? Transaction else {
            throw ApmEncodingError.unsupportedEventType(span)
        }
        
        guard let context = transaction.spanContext as? ApmTransactionContext else {
            throw ApmEncodingError.unsupportedSpanContext(transaction)
        }
        
        let event = transactionEvent(transaction: transaction, context: context)
        return try jsonEncoder.encode(event)
    }
    
    private func transactionEvent(transaction: Transaction, context: ApmTransactionContext) -> TransactionEvent {
        let event = TransactionEvent.Transaction(timestamp: transaction.timestamp,
                                                 type: transaction.type,
                                                 name: transaction.name,
                                                 id: transaction.id,
                                                 traceId: transaction.traceContext.traceId,
                                                 parentId: transaction.traceContext.parentId,
                                                 spanCount: nil,
                                                 duration: transaction.duration,
                                                 result: nil,
                                                 outcome: nil,
                                                 sampled: true,
                                                 context: nil)
        return .init(transaction: event)
    }
}
