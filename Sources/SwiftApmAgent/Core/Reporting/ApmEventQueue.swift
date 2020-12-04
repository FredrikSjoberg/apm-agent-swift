//
//  ApmEventQueue.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmEventQueue: EventQueue {
    
    private let lock = DispatchQueue(label: "com.swiftapmagent.core.reporter.eventqueue", attributes: .concurrent)
    private var batch: ApmBatchEvent?
    
    init() { }
    
    private func enqueue(_ event: Data) {
        if let current = batch {
            current.events.append(event)
        } else {
            batch = ApmBatchEvent(events: [event], status: .readyForDispatch)
        }
    }
    
    // MARK: <EventQueue>
    func push(_ event: Data) {
        lock.async(flags: .barrier) { [weak self] in
            self?.enqueue(event)
        }
    }
    
    var nextBatch: ApmBatchEvent? {
        var result: ApmBatchEvent?
        lock.sync {
            result = batch
            batch = nil
        }
        return result
    }
}
