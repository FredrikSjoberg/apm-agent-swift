//
//  Dispatcher.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal protocol Dispatcher {
    var dispatchFrequency: TimeInterval { get set }
    func start()
}
