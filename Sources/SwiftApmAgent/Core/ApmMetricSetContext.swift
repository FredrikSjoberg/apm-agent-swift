//
//  ApmMetricSetContext.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

internal class ApmMetricSetContext: EventContext {
    
    // MARK: <EventContext>
    static var encoderIdentifier: String {
        return String(describing: Swift.type(of: self))
    }
}
