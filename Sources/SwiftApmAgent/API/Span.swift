//
//  Span.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

@objc
public protocol Span {
    var name: String { get set }
    var type: String { get set }
    var subtype: String? { get set }
    var timestamp: Int64 { get }
    /// Negative duration means no duration
    var duration: Int64 { get set }
    
    var traceContext: TraceContext { get }
    var spanContext: SpanContext { get set }
    
    var id: String { get }
    
    var finished: Bool { get }
    #warning("APM-TODO: Return non-optional Span")
    func createSpan(name: String, type: String) -> Span?
    func activate()
    func deactivate()
    func end()
}
