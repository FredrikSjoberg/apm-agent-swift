//
//  EncoderRepository.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal protocol EncoderRepository {
    func register(intakeEncoders: [String: () -> EventEncoder])
    func encoder(for identifier: String) throws -> EventEncoder
}
