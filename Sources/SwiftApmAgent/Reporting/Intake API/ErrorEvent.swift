//
//  ErrorEvent.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-04.
//

import Foundation

struct ErrorEvent: ReporterEvent {
    
    /// An error or a logged error message captured by an agent occurring in a monitored service
    let error: Error
    
    /// Version: https://github.com/elastic/apm-server/blob/v7.10.1/docs/spec/errors/error.json
    struct Error: Encodable {
        
        /// Recorded time of the event, UTC based and formatted as microseconds since Unix epoch
        let timestamp: Int64
        
        /// Hex encoded 128 random bits ID of the error.
        let id: String
        
        /// Hex encoded 64 random bits ID of the correlated transaction.
        let transactionId: String?
        
        /// Hex encoded 128 random bits ID of the correlated trace.
        let traceId: String
        
        /// Hex encoded 64 random bits ID of the parent transaction or span.
        let parentId: String
        
        /// Data for correlating errors with transactions
        let transaction: Transaction?
        
        struct Transaction: Encodable {
            /// Transactions that are 'sampled' will include all available information. Transactions that are not sampled will not have 'spans' or 'context'. Defaults to true.
            let sampled: Bool?
            
            /// Keyword of specific relevance in the service's domain (eg: 'request', 'backgroundjob', etc)
            let type: String?
        }
        
        let context: IntakeContext?
        
        /// Function call which was the primary perpetrator of this event.
        let culprit: String?
        
        /// Information about the originally thrown error.
        let exception: Exception?
        
        struct Exception: Encodable {
            /// The error code set when the error happened, e.g. database error code.
            let code: Int?
            
            /// The original error message.
            ///
            /// Note: Either message or type is required
            let message: String?
            
            /// Describes the exception type's module namespace.
            let module: String?
            
            /// A stacktrace frame, contains various bits (most optional) describing the context of the frame
            let stacktrace: [Stacktrace]
            
            /// The error type.
            ///
            /// Note: Either message or type is required
            let type: String?
            
            /// Indicator whether the error was caught somewhere in the code or not.
            let handled: Bool?
        }
        
        /// Version: https://github.com/elastic/apm-server/blob/v7.10.1/docs/spec/stacktrace_frame.json
        struct Stacktrace: Encodable {
            /// The absolute path of the file involved in the stack frame
            let absPath: String?
            
            /// Column number
            let colno: Int?
            
            /// The line of code part of the stack frame
            let contextLine: String?
            
            /// The relative filename of the code involved in the stack frame, used e.g. to do error checksumming
            let filename: String?
            
            /// The classname of the code involved in the stack frame
            let classname: String?
            
            /// The function involved in the stack frame
            let function: String?
            
            /// A boolean, indicating if this frame is from a library or user code
            let libraryFrame: Bool?
            
            /// The line number of code part of the stack frame, used e.g. to do error checksumming
            let lineno: Int64?
            
            /// The module to which frame belongs to
            let module: String?
            
            /// The lines of code after the stack frame
            let postContext: [Context]
            
            struct Context: Encodable {
                let type: String
            }
            
            /// The lines of code before the stack frame
            let preContext: [Context]
        }
        
        /// Additional information added when logging the error.
        let log: [Log]
        
        struct Log: Encodable {
            /// The severity of the record.
            let level: String?
            
            /// The name of the logger instance used.
            let loggerName: String?
            
            /// The additionally logged error message.
            let message: String
            
            /// A stacktrace frame, contains various bits (most optional) describing the context of the frame
            let stacktrace: [Stacktrace]
        }
    }
}
