//
//  ApmErrorCaptureContext.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-04.
//

import Foundation

internal class ApmErrorCaptureContext: EventContext {
    let error: Error
    
    init(error: Error) {
        self.error = error
    }
    
    // MARK: <EventContext>
    static var encoderIdentifier: String {
        return String(describing: Swift.type(of: self))
    }
}
