//
//  ApmCoreDataSpanContext.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-22.
//

import Foundation

internal class ApmCoreDataSpanContext: SpanContext {
    
    let name: String
    let dbType: String?
    let statement: String?
    
    var outcome: String?
    var rowsAffected: Int64?
    
    init(name: String,
         dbType: String?,
         statement: String?,
         outcome: String?,
         rowsAffected: Int64?) {
        self.name = name
        self.dbType = dbType
        self.statement = statement
        self.outcome = outcome
        self.rowsAffected = rowsAffected
    }
    
    // MARK: <IntakeEncodable>
    static var encoderIdentifier: String {
        return String(describing: Swift.type(of: self))
    }
}
