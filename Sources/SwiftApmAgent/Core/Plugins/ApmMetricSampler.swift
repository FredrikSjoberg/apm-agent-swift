//
//  ApmMetricSampler.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

#if !os(macOS)
import UIKit
#endif

class ApmMetricSampler: MetricSampler {
    
    private let queue = DispatchQueue(label: "com.swiftapmagent.plugin.system-metric-set")
    private var workItem: DispatchWorkItem?
    
    private var sampleRateSeconds: Int = 30
    
    var gatherMetrics: () -> Void = { }
    
    init() {
        #if !os(macOS)
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.pauseSampler()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.resumeSampler(rate: self.sampleRateSeconds)
        }
        #endif
    }
    
    // MARK: <MetricSampler>
    func pauseSampler() {
        workItem?.cancel()
        workItem = nil
    }
    
    func resumeSampler(rate: Int) {
        workItem?.cancel()
        sampleRateSeconds = rate
        
        guard rate > 0 else {
            return
        }
        
        let item = DispatchWorkItem(qos: .utility) { [weak self] in
            self?.sampleMetrics()
        }
        
        queue.asyncAfter(deadline: .now() + .seconds(sampleRateSeconds), execute: item)
        workItem = item
    }
    
    private func sampleMetrics() {
        gatherMetrics()
        resumeSampler(rate: sampleRateSeconds)
    }
}
