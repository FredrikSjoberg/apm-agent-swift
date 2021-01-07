//
//  ApmSystemMetricSetContext.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

internal struct ApmSystemMetricSetContext: EventContext, CustomStringConvertible {
    
    /// system.cpu.total.norm.pct
    ///
    /// in percent
    var cpuTotalUsage: Double?
    
    /// system.process.cpu.total.norm.pct
    ///
    /// in percent
    var cpuProcessTotalUsage: Double?
    
    /// system.memory.actual.free
    ///
    /// in bytes
    var availableSystemMemory: UInt64?
    
    /// system.memory.total
    ///
    /// in bytes
    var totalSystemMemory: UInt64?
    
    /// system.process.memory.size
    ///
    /// in bytes
    var processMemoryUsage: UInt64?
    
    // MARK: <EventContext>
    static var encoderIdentifier: String {
        return String(describing: Swift.type(of: self))
    }
    
    // MARK: <CustomStringConvertible>
    var description: String {
        let userCpu = cpuTotalUsage != nil ? "\(cpuTotalUsage!)" : "n/a"
        let processCpu = cpuProcessTotalUsage != nil ? "\(cpuProcessTotalUsage!)" : "n/a"
        let freeMem = availableSystemMemory != nil ? "\(availableSystemMemory!)" : "n/a"
        let totalMem = totalSystemMemory != nil ? "\(totalSystemMemory!)" : "n/a"
        let processMem = processMemoryUsage != nil ? "\(processMemoryUsage!)" : "n/a"
        return """
            -+ ApmSystemMetricSetContext
             |   cpuTotalUsage: \(userCpu)
             |   cpuProcessTotalUsage: \(processCpu)
             |   availableSystemMemory: \(freeMem)
             |   totalSystemMemory: \(totalMem)
             |   processMemoryUsage: \(processMem)
            """
    }
}
