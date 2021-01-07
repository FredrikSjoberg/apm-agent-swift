//
//  ApmSystemMetricSetEncoder.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

internal class ApmSystemMetricSetEncoder: EventEncoder {
    private let cpuTotalUsage = "system.cpu.total.norm.pct"
    private let cpuProcessTotalUsage = "system.process.cpu.total.norm.pct"
    private let availableSystemMemory = "system.memory.actual.free"
    private let totalSystemMemory = "system.memory.total"
    private let processMemoryUsage = "system.process.memory.size"
    
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }
    
    func encode(_ event: Event) throws -> Data {
        guard let metricSet = event as? MetricSet else {
            throw ApmEncodingError.unsupportedEventType(event)
        }
        
        guard let context = metricSet.eventContext as? ApmSystemMetricSetContext else {
            throw ApmEncodingError.unsupportedEventContext(event)
        }
        
        guard let intakeEvent = metricEvent(metric: metricSet, context: context) else {
            throw ApmSystemMetricSetPlugin.Error.noMetricsToGather
        }
        
        return try jsonEncoder.encode(intakeEvent)
    }
    
    private func metricEvent(metric: MetricSet, context: ApmSystemMetricSetContext) -> MetricsetEvent? {
        var samples: [String: MetricsetEvent.Metricset.Sample] = [:]
        [
            cpuTotalUsageSample(context: context),
            cpuProcessTotalUsageSample(context: context),
            availableSystemMemorySample(context: context),
            totalSystemMemorySample(context: context),
            processMemoryUsageSample(context: context)
        ]
        .compactMap {
            $0
        }
        .forEach { (key, value) in
            samples[key] = value
        }
        
        guard !samples.isEmpty else {
            return nil
        }
        
        let metricSet = MetricsetEvent.Metricset(timestamp: metric.timestamp,
                                                 samples: samples)
        return .init(metricset: metricSet)
    }
    
    private func cpuTotalUsageSample(context: ApmSystemMetricSetContext) -> (String, MetricsetEvent.Metricset.Sample)? {
        guard let value = context.cpuTotalUsage else {
            return nil
        }
        return (cpuTotalUsage, .init(value: .double(value)))
    }
    
    private func cpuProcessTotalUsageSample(context: ApmSystemMetricSetContext) -> (String, MetricsetEvent.Metricset.Sample)? {
        guard let value = context.cpuProcessTotalUsage else {
            return nil
        }
        return (cpuProcessTotalUsage, .init(value: .double(value)))
    }
    
    private func availableSystemMemorySample(context: ApmSystemMetricSetContext) -> (String, MetricsetEvent.Metricset.Sample)? {
        guard let value = context.availableSystemMemory else {
            return nil
        }
        return (availableSystemMemory, .init(value: .uinteger64(value)))
    }
    
    private func totalSystemMemorySample(context: ApmSystemMetricSetContext) -> (String, MetricsetEvent.Metricset.Sample)? {
        guard let value = context.totalSystemMemory else {
            return nil
        }
        return (totalSystemMemory, .init(value: .uinteger64(value)))
    }
    
    private func processMemoryUsageSample(context: ApmSystemMetricSetContext) -> (String, MetricsetEvent.Metricset.Sample)? {
        guard let value = context.processMemoryUsage else {
            return nil
        }
        return (processMemoryUsage, .init(value: .uinteger64(value)))
    }
}
