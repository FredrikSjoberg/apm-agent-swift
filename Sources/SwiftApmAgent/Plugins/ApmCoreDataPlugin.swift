//
//  ApmCoreDataPlugin.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-22.
//

import Foundation

#if !os(macOS)
import CoreData

class ApmCoreDataPlugin: Plugin {
    init() { }
    
    func configure() {
        NSManagedObjectContext.apm_swizzleFetchRequest()
    }
    
    internal static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    public var intakeEncoders: [String: () -> IntakeEncoder] {
        return [
            ApmCoreDataSpanContext.encoderIdentifier: { ApmCoreDataSpanEncoder(jsonEncoder: ApmCoreDataPlugin.jsonEncoder) }
        ]
    }
}

#endif
