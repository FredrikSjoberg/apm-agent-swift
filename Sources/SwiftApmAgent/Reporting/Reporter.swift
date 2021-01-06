//
//  Reporter.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal protocol Reporter {
    func report(_ event: Event)
}
