//
//  Tracer.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

public protocol Tracer: AnyObject {
    // MARK: Transaction
    func startRootTransaction(name: String, type: String) -> Transaction
    func endTransaction(_ transaction: Transaction)
    
    // MARK: Span
    func startSpan(name: String, type: String) -> Span
    func endSpan(_ span: Span)
    
    // MARK: Status
    func currentTransaction() -> Transaction?
    func getActive() -> Span?
    func getActiveSpan() -> Span?
    func activate(_ span: Span)
    func deactivate(_ span: Span)
}
