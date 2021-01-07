//
//  Metricset.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

public protocol MetricSet: Event {
    func report()
}
