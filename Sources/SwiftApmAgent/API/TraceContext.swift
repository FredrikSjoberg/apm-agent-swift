//
//  TraceContext.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

public protocol TraceContext {
    #warning("APM-TODO: Implement https://w3c.github.io/trace-context/#traceparent-field")
    
    var traceId: String { get }
    var transactionId: String { get }
    var parentId: String? { get }
    var serviceName: String? { get }
    
    func createChild(parentId: String?) -> TraceContext
}
