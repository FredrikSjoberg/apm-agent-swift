//
//  IntakeEncoder.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

public protocol EventEncoder {
    func encode(_ event: Event) throws -> Data
}
