//
//  ApmCoreDataRequestHelper.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-22.
//

import Foundation

#if !os(macOS)
import CoreData

internal class ApmCoreDataRequestHelper: NSObject {
    static let fetch = "FETCH"
    static let db = "db"
    static let success = "success"
    static let failure = "failure"
    static let coreData = "CoreData"
    
    static func createSpan(parent: Span?, request: NSFetchRequest<NSFetchRequestResult>) -> Span? {
        let name = "\(fetch) \(request.entityName ?? "Unknown")"
        var span = parent?.createSpan(name: name, type: db)
        let stores = request.affectedStores?.map {
            $0.type
        }
        .joined(separator: "|")
        
        span?.eventContext = ApmCoreDataSpanContext(name: coreData,
                                                   dbType: stores,
                                                   statement: requestConfiguration(request),
                                                   outcome: nil,
                                                   rowsAffected: nil)
        
        return span
    }
    
    private static func requestConfiguration(_ request: NSFetchRequest<NSFetchRequestResult>) -> String? {
        return request.predicate?.description
    }
    
    // MARK: Handle results
    static func handleSuccess(_ result: [Any], span: Span?) {
        let context = span?.eventContext as? ApmCoreDataSpanContext
        context?.outcome = ApmCoreDataRequestHelper.success
        context?.rowsAffected = Int64(result.count)
        span?.deactivate()
        span?.end()
    }
    
    static func handleFailure(_ error: Error?, span: Span?) {
        let context = span?.eventContext as? ApmCoreDataSpanContext
        context?.outcome = ApmCoreDataRequestHelper.failure
        
        if let error = error {
            let errorCapture = span?.captureError(error)
            errorCapture?.report()
        }
        
        span?.deactivate()
        span?.end()
    }
}
#endif
