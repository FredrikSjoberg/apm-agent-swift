//
//  ApmTraceContext.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmTraceContext: TraceContext {
    private let version: IdRepresentation = ApmId([0])
    private lazy var flags: IdRepresentation = {
        return ApmId([1])
    }()
    
    var traceparentHeader: String {
        return [version, traceId, transactionId, flags].map {
            $0.hexString
        }
        .joined(separator: "-")
    }
    
    let traceId: IdRepresentation
    let transactionId: IdRepresentation
    let parentId: IdRepresentation?
    let serviceName: String?
    
    init(traceId: IdRepresentation,
         transactionId: IdRepresentation,
         parentId: IdRepresentation? = nil,
         serviceName: String? = nil) {
        self.traceId = traceId
        self.transactionId = transactionId
        self.parentId = parentId
        self.serviceName = serviceName
    }
    
    func createChild(parentId: IdRepresentation?) -> TraceContext {
        return ApmTraceContext(traceId: traceId,
                               transactionId: transactionId,
                               parentId: parentId,
                               serviceName: serviceName)
    }
}
