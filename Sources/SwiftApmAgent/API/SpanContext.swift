//
//  SpanContext.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

@objc
public protocol SpanContext {
    static var encoderIdentifier: String { get }
}
