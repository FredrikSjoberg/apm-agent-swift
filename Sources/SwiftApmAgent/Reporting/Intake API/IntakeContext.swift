//
//  IntakeContext.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-04.
//

import Foundation

/// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/context.json
struct IntakeContext: Encodable {
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
