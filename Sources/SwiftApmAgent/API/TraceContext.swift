//
//  TraceContext.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

public protocol TraceContext {
    var traceparentHeader: String { get }
    
    var traceId: IdRepresentation { get }
    var transactionId: IdRepresentation { get }
    var parentId: IdRepresentation? { get }
    var serviceName: String? { get }
    
    func createChild(parentId: IdRepresentation?) -> TraceContext
}
