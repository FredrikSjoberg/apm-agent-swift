//
//  NSManagedObjectContext+ApmPlugin.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-22.
//

import Foundation

#if !os(macOS)
import CoreData

extension NSManagedObjectContext {
    // MARK: Fetch
    @objc
    func apmFetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        return try apmBridgedFetch(request)
    }
    
    private func apmBridgedFetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        let parent = ApmAgent.shared().tracer.getActive()
        let span = ApmCoreDataRequestHelper.createSpan(parent: parent, request: request)
        span?.activate()
        do {
            let result = try apmFetch(request)
            ApmCoreDataRequestHelper.handleSuccess(result, span: span)
            return result
        } catch {
            ApmCoreDataRequestHelper.handleFailure(error, span: span)
            throw error
        }
    }
    
    // MARK: Method swizzling
    static func apm_swizzleFetchRequest() {
        let selector = #selector(NSManagedObjectContext.fetch(_:))
        let apmSelector = #selector(NSManagedObjectContext.apmFetch(_:))
        
        guard let method1 = class_getInstanceMethod(NSManagedObjectContext.self, selector),
              let method2 = class_getInstanceMethod(NSManagedObjectContext.self, apmSelector) else {
            return
        }
        
        method_exchangeImplementations(method1, method2)
    }
}

#endif
