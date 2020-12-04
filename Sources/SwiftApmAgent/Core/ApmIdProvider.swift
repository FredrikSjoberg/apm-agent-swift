//
//  ApmIdProvider.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

internal class ApmIdProvider: IdProvider {
    
    func generateId() -> String {
        #warning("APM-TODO: Use correct format for ids")
        return UUID().uuidString
    }
    
    func generateTraceId() -> String {
        #warning("APM-TODO: Use correct format for traceIds")
        return UUID().uuidString
    }
}
