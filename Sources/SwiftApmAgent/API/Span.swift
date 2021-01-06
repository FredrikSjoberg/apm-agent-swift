//
//  Span.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

public protocol Span: Event {
    var name: String { get set }
    var type: String { get set }
    var subtype: String? { get set }
    
    /// How long the transaction took to complete, in ms with 3 decimal points
    ///
    /// Negative duration means no duration
    var duration: Int64 { get set }
    
    var finished: Bool { get }
    #warning("APM-TODO: Return non-optional Span")
    func createSpan(name: String, type: String) -> Span?
    func captureError(_ error: Error) -> ErrorCapture?
    
    func activate()
    func deactivate()
    func end()
}
