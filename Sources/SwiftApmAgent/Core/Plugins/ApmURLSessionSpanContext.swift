//
//  ApmURLSessionSpanContext.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

internal class ApmURLSessionSpanContext: SpanContext {
    let method: String
    let url: URL
    var statusCode: Int?
    var finished: Bool = false
    
    var destination: Destination?
    
    init(method: String, url: URL) {
        self.method = method
        self.url = url
    }
    
    struct Destination {
        let address: String?
        let port: Int?
        let service: Service?
        
        struct Service {
            let name: String?
            let resource: String?
            let type: String
        }
    }
    
    // MARK: <IntakeEncodable>
    static var encoderIdentifier: String {
        return String(describing: Swift.type(of: self))
    }
}
