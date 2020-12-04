//
//  ApmTraceContext.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmTraceContext: TraceContext {
    
    let traceId: String
    let transactionId: String
    let parentId: String?
    let serviceName: String?
    
    init(traceId: String,
         transactionId: String,
         parentId: String? = nil,
         serviceName: String? = nil) {
        self.traceId = traceId
        self.transactionId = transactionId
        self.parentId = parentId
        self.serviceName = serviceName
    }
    
    func createChild(parentId: String?) -> TraceContext {
        return ApmTraceContext(traceId: traceId,
                               transactionId: transactionId,
                               parentId: parentId,
                               serviceName: serviceName)
    }
}
