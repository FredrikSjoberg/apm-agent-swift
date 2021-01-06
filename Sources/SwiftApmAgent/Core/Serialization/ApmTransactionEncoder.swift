//
//  ApmTransactionEncoder.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmTransactionEncoder: EventEncoder {
    
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }
    
    func encode(_ event: Event) throws -> Data {
        guard let transaction = event as? Transaction else {
            throw ApmEncodingError.unsupportedEventType(event)
        }
        
        guard let context = transaction.eventContext as? ApmTransactionContext else {
            throw ApmEncodingError.unsupportedEventContext(transaction)
        }
        
        let intakeEvent = transactionEvent(transaction: transaction, context: context)
        return try jsonEncoder.encode(intakeEvent)
    }
    
    private func transactionEvent(transaction: Transaction, context: ApmTransactionContext) -> TransactionEvent {
        let event = TransactionEvent.Transaction(timestamp: transaction.timestamp,
                                                 type: transaction.type,
                                                 name: transaction.name,
                                                 id: transaction.id.hexString,
                                                 traceId: transaction.traceContext.traceId.hexString,
                                                 parentId: transaction.traceContext.parentId?.hexString,
                                                 spanCount: spanCount(),
                                                 duration: transaction.duration,
                                                 result: nil,
                                                 outcome: nil,
                                                 sampled: true,
                                                 context: nil)
        return .init(transaction: event)
    }
    
    private func spanCount() -> TransactionEvent.Transaction.SpanCount {
        return .init(started: 0, dropped: nil)
    }
}
