//
//  ApmURLSessionPlugin.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

public class ApmURLSessionPlugin: Plugin {
    internal static let logger: Logger = LoggerFactory.getLogger(ApmURLSessionPlugin.self, .info)
    internal static let elasticApmTraceHeader = "Elastic-Apm-Traceparent"
    
    public func configure() {
        ApmURLSessionPlugin.apm_swizzleDataTaskRequestImpl()
        ApmURLSessionPlugin.apm_swizzleDataTaskURLImpl()
    }
    
    internal static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    public var intakeEncoders: [String: () -> IntakeEncoder] {
        return [
            ApmURLSessionSpanContext.encoderIdentifier: { ApmURLSessionSpanEncoder(jsonEncoder: ApmURLSessionPlugin.jsonEncoder) }
        ]
    }
    
    /// Specified hosts will be excluded from tracing
    public var excludedHosts: [String] = []
    
    private static func apm_swizzleDataTaskURLImpl() {
        let instance = URLSession.shared
        guard let defaultClass: AnyClass = object_getClass(instance) else {
            return
        }
        
        let requestSelector = #selector((URLSession.dataTask(with:completionHandler:))
            as (URLSession) -> (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let apmRequestSelector = #selector((URLSession.apmDataTaskURL(with:completionHandler:))
            as (URLSession) -> (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        guard let method1 = class_getInstanceMethod(defaultClass, requestSelector),
              let method2 = class_getInstanceMethod(defaultClass, apmRequestSelector) else {
            return
        }
        
        method_exchangeImplementations(method1, method2)
    }
    
    private static func apm_swizzleDataTaskRequestImpl() {
        let instance = URLSession.shared
        guard let defaultClass: AnyClass = object_getClass(instance) else {
            return
        }
        
        let requestSelector = #selector((URLSession.dataTask(with:completionHandler:))
            as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let apmRequestSelector = #selector((URLSession.apmDataTaskRequest(with:completionHandler:))
            as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        guard let method1 = class_getInstanceMethod(defaultClass, requestSelector),
              let method2 = class_getInstanceMethod(defaultClass, apmRequestSelector) else {
            return
        }
        
        method_exchangeImplementations(method1, method2)
    }
}
