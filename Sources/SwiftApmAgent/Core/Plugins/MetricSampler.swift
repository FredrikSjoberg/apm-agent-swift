//
//  MetricSampler.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

protocol MetricSampler: class {
    var gatherMetrics: () -> Void { get set }
    
    func pauseSampler()
    
    /// Resume sampling with `rate` in seconds
    ///
    /// - Parameters:
    ///     - rate: The rate to sample this `MetricSet` given in secnds. 0 indicates a disabled metric
    func resumeSampler(rate: Int)
}
