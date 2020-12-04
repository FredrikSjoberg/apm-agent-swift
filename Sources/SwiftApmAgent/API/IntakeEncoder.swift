//
//  IntakeEncoder.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

@objc
public protocol IntakeEncoder {
    func encode(_ span: Span) throws -> Data
}
