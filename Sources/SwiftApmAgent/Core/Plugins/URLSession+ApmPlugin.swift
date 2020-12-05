//
//  URLSession+ApmPlugin.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

internal extension URLSession {
    
    @objc
    func apmDataTaskRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return apmBridgedDataTaskRequest(with: request, completionHandler: completionHandler)
    }
    
    private func apmBridgedDataTaskRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        let parent = ApmAgent.shared().tracer.getActive()
        let activeTransactionId = ApmAgent.shared().tracer.currentTransaction()?.id
        let span = ApmURLRequestHelper.createSpan(parent: parent, request: request)
        span?.activate()
        
        return apmDataTaskRequest(with: request) { data, response, error in
            if let context = span?.spanContext as? ApmURLSessionSpanContext {
                context.statusCode = (response as? HTTPURLResponse)?.statusCode
                context.finished = true
            }
            let currentTransactionId = ApmAgent.shared().tracer.currentTransaction()?.id
            span?.deactivate()
            if let activeTransactionId = activeTransactionId,
               let currentTransactionId = currentTransactionId,
               activeTransactionId != currentTransactionId {
                ApmURLSessionPlugin.logger.error("Parent transaction with transaction.id=\(activeTransactionId) no longer active!")
            }
            span?.end()
            
            completionHandler(data, response, error)
            
        }
    }
    
    @objc
    func apmDataTaskURL(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return apmBridgedDataTaskURL(with: url, completionHandler: completionHandler)
    }
    
    private func apmBridgedDataTaskURL(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return apmDataTaskURL(with: url) { data, response, error in
            completionHandler(data, response, error)
        }
    }
}
