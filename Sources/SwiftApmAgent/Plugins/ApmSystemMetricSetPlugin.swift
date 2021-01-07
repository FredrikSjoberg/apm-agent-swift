//
//  ApmSystemMetricSetPlugin.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

class ApmSystemMetricSetPlugin: Plugin {
    enum Error: Swift.Error {
        case noMetricsToGather
    }
    
    private let logger: Logger
    private let sampler: MetricSampler
    private let sampleRateSeconds: Int
    
    init(sampleRateSeconds: Int = 30,
         sampler: MetricSampler = ApmMetricSampler(),
         logger: Logger = LoggerFactory.getLogger(ApmSystemMetricSetPlugin.self)) {
        self.sampleRateSeconds = sampleRateSeconds
        self.sampler = sampler
        self.logger = logger
    }
    
    func configure() {
        sampler.gatherMetrics = { [weak self] in
            self?.gatherMetrics()
        }
        sampler.resumeSampler(rate: sampleRateSeconds)
    }
    
    internal static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    private func gatherMetrics() {
        var metric = ApmAgent.shared().tracer.createMetricSet()
        let (userCpu, totalCpu) = MachineInfo.cpuLoad
        let availableSystemMemory = MachineInfo.availableSystemMemory
        let totalSystemMemory = MachineInfo.totalSystemMemory
        let processMemoryUsage = MachineInfo.processMemoryUsage
        guard userCpu != nil || totalCpu != nil || availableSystemMemory != nil || totalSystemMemory != nil || processMemoryUsage != nil else {
            logger.debug("No metrics to gather")
            return
        }
        let context = ApmSystemMetricSetContext(cpuTotalUsage: userCpu,
                                                cpuProcessTotalUsage: totalCpu,
                                                availableSystemMemory: availableSystemMemory,
                                                totalSystemMemory: totalSystemMemory,
                                                processMemoryUsage: processMemoryUsage)
        metric?.eventContext = context
        logger.info("Gathering metrics \n \(context)")
        metric?.report()
    }
    
    // MARK: <Plugin>
    public var intakeEncoders: [String: () -> EventEncoder] {
        return [
            ApmSystemMetricSetContext.encoderIdentifier: { ApmSystemMetricSetEncoder(jsonEncoder: ApmSystemMetricSetPlugin.jsonEncoder) }
        ]
    }
}
