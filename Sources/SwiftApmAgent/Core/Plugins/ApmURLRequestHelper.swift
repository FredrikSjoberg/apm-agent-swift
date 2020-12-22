//
//  ApmURLRequestHelper.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

internal class ApmURLRequestHelper: NSObject {
    
    static let externalType: String = "external"
    static let httpSubtype: String = "http"
    static let defaultSpanName: String = "DefaultApmURLSessionSpanName"
    static let httpScheme: String = "http"
    static let httpsScheme: String = "https"
    static let httpPort: Int = 80
    static let httpsPort: Int = 443
    
    static var requestFilter: [String] = []
    
    static func createSpan(parent: Span?, request: URLRequest) -> Span? {
        var span = parent?.createSpan(name: spanName(from: request),
                                      type: ApmURLRequestHelper.externalType)
        
        span?.subtype = ApmURLRequestHelper.httpSubtype
        
        guard let method = request.httpMethod,
              let url = request.url else {
            ApmURLSessionPlugin.logger.error("Invalid URLRequest, missing httpMethod=\(request.httpMethod ?? "nil") or url=\(request.url?.host ?? "nil")")
            return span
        }
        
        let context = ApmURLSessionSpanContext(method: method,
                                               url: url)
        context.destination = destination(url: url)
        span?.spanContext = context
        return span
    }
    
    private static func spanName(from request: URLRequest) -> String {
        guard let method = request.httpMethod, let host = request.url?.host else {
            return defaultSpanName
        }
        return "\(method) \(host)"
    }
    
    private static func destination(url: URL) -> ApmURLSessionSpanContext.Destination {
        return .init(address: url.host,
                     port: port(url: url),
                     service: service(url: url))
    }
    
    private static func service(url: URL) -> ApmURLSessionSpanContext.Destination.Service {
        var name: String?
        if let scheme = url.scheme, let host = url.host {
            name = scheme + "://" + host
        }
        var resource: String?
        if let host = url.host, let port = port(url: url) {
            resource = host + ":" + "\(port)"
        }
        
        return .init(name: name,
                     resource: resource,
                     type: externalType)
    }
    
    private static func port(url: URL) -> Int? {
        if let port = url.port {
            return port
        }
        
        guard let scheme = url.scheme else {
            return nil
        }
        
        switch scheme {
        case httpScheme: return httpPort
        case httpsScheme: return httpsPort
        default: return nil
        }
    }
}
