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
        
        let spanCount: SpanCount?
        
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
        let context: Context?
        
        /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/context.json
        struct Context: Encodable {
            /// An object containing contextual data of the related http request.
            let response: Response?
            
            /// HTTP response object, used by error, span and transction documents
            ///
            /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/http_response.json
            struct Response: Encodable {
                /// The status code of the http request.
                let statusCode: Int?
                
                /// Total size of the payload.
                let transferSize: Int64?
                
                /// The encoded size of the payload.
                let encodedBodySize: Int64?
                
                /// The decoded size of the payload.
                let decodedBodySize: Int64?
                
                /// The response headers
                let headers: [String: String]
                
                /// A boolean indicating whether the response was finished or not
                let finished: Bool
            }
            
            /// If a log record was generated as a result of a http request, the http interface can be used to collect this information.
            let request: Request?
            
            /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/request.json
            struct Request: Encodable {
                /// Data should only contain the request body (not the query string). It can either be a dictionary (for standard HTTP requests) or a raw request body.
                let body: Data?
                
                /// The env variable is a compounded of environment information passed from the webserver.
                let env: [String: String]
                
                /// Should include any headers sent by the requester. Cookies will be taken by headers if supplied.
                let headers: [String: String]
                
                /// HTTP version
                let httpVersion: String?
                
                /// The method of the http request.
                let method: String
                
                /// A complete Url, with scheme, host and path.
                let url: URL
                
                struct URL: Encodable {
                    /// The raw, unparsed URL of the HTTP request line, e.g https://example.com:443/search?q=elasticsearch.
                    ///
                    /// This URL may be absolute or relative. For more details, see https://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5.1.2.
                    let raw: String?
                    
                    /// The protocol of the request, e.g. 'https:'.
                    let `protocol`: String?
                    
                    /// The full, possibly agent-assembled URL of the request, e.g https://example.com:443/search?q=elasticsearch#top.
                    let full: String?
                    
                    /// The hostname of the request, e.g. 'example.com'.
                    let hostname: String?
                    
                    /// The port of the request, e.g. '443'
                    let port: Int?
                    
                    /// The path of the request, e.g. '/search'
                    let pathname: String?
                    
                    /// The search describes the query string of the request. It is expected to have values delimited by ampersands.
                    let search: String?
                    
                    /// A parsed key-value object of cookies
                    let cookies: [String: String]
                }
            }
        }
    }
}
