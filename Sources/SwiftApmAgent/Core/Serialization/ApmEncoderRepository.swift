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
    
    internal static let defaultEncoders: [String: () -> IntakeEncoder] = [
        ApmTransactionContext.encoderIdentifier: { ApmTransactionEncoder(jsonEncoder: jsonEncoder) },
        ApmSpanContext.encoderIdentifier: { ApmSpanEncoder(jsonEncoder: jsonEncoder) }
    ]
    
    private var encoderGenerators: [String: () -> IntakeEncoder]
    
    init(encoderGenerators: [String: () -> IntakeEncoder] = ApmEncoderRepository.defaultEncoders) {
        self.encoderGenerators = encoderGenerators
    }
    
    func encoder(for identifier: String) throws -> IntakeEncoder {
        guard let generator = encoderGenerators[identifier] else {
            throw ApmEncodingError.encoderNotFound(identifier)
        }
        return generator()
    }
}
