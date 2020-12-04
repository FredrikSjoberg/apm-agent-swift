//
//  SpanEvent.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

struct SpanEvent: ReporterEvent {
    /// An event captured by an agent occurring in a monitored service
    let span: Span
    
    /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/spans/span.json
    struct Span: Encodable {
        /// Recorded time of the event, UTC based and formatted as microseconds since Unix epoch
        let timestamp: Int64
        
        /// Keyword of specific relevance in the service's domain (eg: 'db.postgresql.query', 'template.erb', etc)
        let type: String
        
        /// A further sub-division of the type (e.g. postgresql, elasticsearch)
        let subtype: String?
        
        /// Hex encoded 64 random bits ID of the span.
        let id: String
        
        /// Hex encoded 64 random bits ID of the correlated transaction.
        let transactionId: String?
        
        /// Hex encoded 128 random bits ID of the correlated trace.
        let traceId: String
        
        /// Hex encoded 64 random bits ID of the parent transaction or span.
        let parentId: String
        
        /// List of successor transactions and/or spans.
        let childIds: [String]
        
        /// Offset relative to the transaction's timestamp identifying the start of the span, in milliseconds
        let start: Int64?
        
        /// The specific kind of event within the sub-type represented by the span (e.g. query, connect)
        let action: String?
        
        /// The outcome of the span: success, failure, or unknown. Outcome may be one of a limited set of permitted values describing the success or failure of the span.
        ///
        /// This field can be used for calculating error rates for outgoing requests.
        let outcome: String?
        
        /// Any other arbitrary data captured by the agent, optionally provided by the user
        let context: Context?
        
        struct Context: Encodable {
            /// An object containing contextual data about the destination for spans
            let destination: Destination?
            
            struct Destination: Encodable {
                /// Destination network address: hostname (e.g. 'localhost'), FQDN (e.g. 'elastic.co'), IPv4 (e.g. '127.0.0.1') or IPv6 (e.g. '::1')
                let address: String?
                
                /// Destination network port (e.g. 443)
                let port: Int?
                
                /// Destination service context
                let service: Service?
                
                struct Service: Encodable {
                    /// Type of the destination service (e.g. 'db', 'elasticsearch'). Should typically be the same as span.type.
                    let type: String
                    
                    /// Identifier for the destination service (e.g. 'http://elastic.co', 'elasticsearch', 'rabbitmq'
                    let name: String
                    
                    /// Identifier for the destination service resource being operated on (e.g. 'http://elastic.co:80', 'elasticsearch', 'rabbitmq/queue_name')
                    let resource: String
                }
            }
            
            /// An object containing contextual data for database spans
            let db: Db?
            
            struct Db: Encodable {
                /// Database instance name
                let instance: String?
                
                /// Database link
                let link: String?
                
                /// A database statement (e.g. query) for the given database type
                ///
                /// Example: SELECT * FROM product_types WHERE user_id = 123
                let statement: String?
                
                /// Database type. For any SQL database, \"sql\". For others, the lower-case database category, e.g. \"cassandra\", \"hbase\", or \"redis\"
                let type: String?
                
                /// Username for accessing database
                let user: String?
                
                /// "Number of rows affected by the SQL statement (if applicable)
                let rowsAffected: Int64?
            }
            
            /// An object containing contextual data of the related http request.
            let http: Http?
            
            struct Http: Encodable {
                /// The raw url of the correlating http request.
                let url: String?
                
                /// The method of the http request.
                let method: String?
                
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
                }
            }
            
            /// Service related information can be sent per event.
            ///
            /// Provided information will override the more generic information from metadata, non provided fields will be set according to the metadata information.
            let service: Service?
            
            struct Service: Encodable {
                /// Name and version of the Elastic APM agent
                let agent: Agent?
                
                struct Agent: Encodable {
                    /// Name of the Elastic APM agent, e.g 'SwiftApmAgent'
                    let name: String?
                    
                    /// Version of the Elastic APM agent, e.g. '1.0.0'
                    let version: String?
                }
                
                /// Immutable name of the service emitting this event
                let name: String?
            }
        }
        
        /// Duration of the span in milliseconds
        let duration: Int64
        
        /// Generic designation of a span in the scope of a transaction
        let name: String
    }
}
