//
//  ApmEncoderRepository.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmEncoderRepository: EncoderRepository {
    
    internal static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    internal static let defaultEncoders: [String: () -> EventEncoder] = [
        ApmTransactionContext.encoderIdentifier: { ApmTransactionEncoder(jsonEncoder: jsonEncoder) },
        ApmSpanContext.encoderIdentifier: { ApmSpanEncoder(jsonEncoder: jsonEncoder) },
        ApmErrorCaptureContext.encoderIdentifier: { ApmErrorCaptureEncoder(jsonEncoder: jsonEncoder) }
    ]
    
    private var encoderGenerators: [String: () -> EventEncoder]
    
    init(encoderGenerators: [String: () -> EventEncoder] = ApmEncoderRepository.defaultEncoders) {
        self.encoderGenerators = encoderGenerators
    }
    
    func register(intakeEncoders: [String: () -> EventEncoder]) {
        intakeEncoders.forEach { key, value in
            encoderGenerators[key] = value
        }
    }
    
    func encoder(for identifier: String) throws -> EventEncoder {
        guard let generator = encoderGenerators[identifier] else {
            throw ApmEncodingError.encoderNotFound(identifier)
        }
        return generator()
    }
}
