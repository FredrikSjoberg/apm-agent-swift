//
//  ApmBatchEvent.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmBatchEvent {
    var events: [Data]
    var status: DispatchStatus
    
    init(events: [Data],
         status: DispatchStatus = .readyForDispatch) {
        self.events = events
        self.status = status
    }
    
    enum DispatchStatus {
        case readyForDispatch
        case dispatching
        case completed
        case failed(Error)
    }
}
