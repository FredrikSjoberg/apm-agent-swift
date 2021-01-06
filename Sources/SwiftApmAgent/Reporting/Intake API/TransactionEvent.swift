//
//  TransactionEvent.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

struct TransactionEvent: ReporterEvent {
    /// An event corresponding to an incoming request or similar task occurring in a monitored service
    let transaction: Transaction
    
    /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/transactions/transaction.json
    struct Transaction: Encodable {
        /// Recorded time of the event, UTC based and formatted as microseconds since Unix epoch
        let timestamp: Int64
        
        /// Keyword of specific relevance in the service's domain (eg: 'request', 'backgroundjob', etc)
        let type: String
        
        /// Generic designation of a transaction in the scope of a single service (eg: 'GET /users/:id')
        let name: String
        
        /// Hex encoded 64 random bits ID of the transaction.
        let id: String
        
        /// Hex encoded 128 random bits ID of the correlated trace.
        let traceId: String
        
        /// Hex encoded 64 random bits ID of the parent transaction or span. Only root transactions of a trace do not have a parent_id, otherwise it needs to be set.
        let parentId: String?
        
        let spanCount: SpanCount
        
        struct SpanCount: Encodable {
            /// Number of correlated spans that are recorded.
            let started: Int
            
            /// Number of spans that have been dropped by the agent recording the transaction.
            let dropped: Int?
        }
        
        /// How long the transaction took to complete, in ms with 3 decimal points
        let duration: Int64
        
        /// The result of the transaction. For HTTP-related transactions, this should be the status code formatted like 'HTTP 2xx'.
        let result: String?
        
        /// The outcome of the transaction: success, failure, or unknown. This is similar to 'result', but has a limited set of permitted values describing the success or failure of the transaction from the service's perspective. This field can be used for calculating error rates for incoming requests.
        ///
        /// Permitted values:
        ///  * success
        ///  * failure
        ///  * unknown
        ///
        let outcome: String?
        
        /// Transactions that are 'sampled' will include all available information. Transactions that are not sampled will not have 'spans' or 'context'. Defaults to true.
        let sampled: Bool
        
        /// Any arbitrary contextual information regarding the event, captured by the agent, optionally provided by the user
        let context: IntakeContext?
    }
}
