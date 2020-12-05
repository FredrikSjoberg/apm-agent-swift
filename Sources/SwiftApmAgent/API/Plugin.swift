//
//  Plugin.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

public protocol Plugin {
    func configure()
    
    /// Specified encoders will be registered to handle intake encoding for the associated `SpanContext`
    ///
    /// - Key: `encoderIdentifier` identifying the `SpanContext`
    /// - Value: generator closure resulting in an `IntakeEncoder` that will handle encoding of the associated `SpanContext`
    ///
    var intakeEncoders: [String: () -> IntakeEncoder] { get }
}
