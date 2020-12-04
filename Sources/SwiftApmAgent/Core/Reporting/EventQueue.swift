//
//  EventQueue.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal protocol EventQueue {
    func push(_ event: Data)
    var nextBatch: ApmBatchEvent? { get }
}
