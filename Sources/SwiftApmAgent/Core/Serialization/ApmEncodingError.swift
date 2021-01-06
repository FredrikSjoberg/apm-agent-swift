//
//  ApmEncodingError.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal enum ApmEncodingError: Error {
    case encoderNotFound(String)
    case unsupportedEventContext(Event)
    case unsupportedEventType(Event)
}
