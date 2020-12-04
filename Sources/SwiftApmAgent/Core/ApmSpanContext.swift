//
//  ApmSpanContext.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmSpanContext: SpanContext {
    // MARK: <SpanContext>
    static var encoderIdentifier: String {
        return String(describing: Swift.type(of: self))
    }
}
