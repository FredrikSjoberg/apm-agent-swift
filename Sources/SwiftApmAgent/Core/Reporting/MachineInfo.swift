//
//  MachineInfo.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-07.
//

import Foundation

struct MachineInfo {
    private static let hwMachine = "hw.machine"
    private static let hwModel = "hw.model"
    private static let objectiveC = "ObjectiveC"
    
    static var pid: Int {
        return Int(ProcessInfo().processIdentifier)
    }
    
    static var processName: String {
        return ProcessInfo().processName
    }
    
    static var processArguments: [String] {
        return ProcessInfo().arguments
    }
    
    static var hostName: String {
        return ProcessInfo().hostName
    }
    
    static var architecture: String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(i386)
        return "i386"
        #elseif arch(arm)
        return "arm"
        #elseif arch(arm64)
        return "arm64"
        #else
        return "unknown"
        #endif
    }
    
    /// NOTE: *Corrected* on iOS to fetch hw.model instead of hw.machine
    static var machine: String {
        #if os(iOS) && !arch(x86_64) && !arch(i386)
        return sysctl(hwModel)
        #else
        return sysctl(hwMachine)
        #endif
    }
    
    /// NOTE: *Corrected* on iOS to fetch hw.machine instead of hw.model
    static var model: String {
        #if os(iOS) && !arch(x86_64) && !arch(i386)
        return sysctl(hwMachine)
        #else
        return sysctl(hwModel)
        #endif
    }
    
    private static func sysctl(_ name: String) -> String {
        var size: Int = 0
        sysctlbyname(name, nil, &size, nil, 0)
        var res = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &res, &size, nil, 0)
        return String(cString: res)
    }
    
    static var runtimeName: String? {
        #if canImport(ObjectiveC)
        return objectiveC
        #else
        return nil
        #endif
    }
    
    static var runtimeVersion: String? {
        #if canImport(ObjectiveC)
        return "\(OBJC_API_VERSION)"
        #else
        return nil
        #endif
    }
    
    /// Returns the cpu load for process and system respectively
    static var cpuLoad: (process: Double?, system: Double?) {
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()
        
        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        guard result == KERN_SUCCESS else {
            return (nil, nil)
        }
        
        let usrTicks = Double(cpuLoadInfo.cpu_ticks.0)
        let systTicks = Double(cpuLoadInfo.cpu_ticks.1)
        let idleTicks = Double(cpuLoadInfo.cpu_ticks.2)
        let niceTicks = Double(cpuLoadInfo.cpu_ticks.3)
        
        let totalTicks = usrTicks + systTicks + idleTicks + niceTicks
        
        let sys = systTicks / totalTicks
        let usr = (usrTicks + niceTicks) / totalTicks
        return (usr, sys)
    }
    
    /// in bytes
    static var processMemoryUsage: UInt64? {
        let taskVMInfoCount = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        guard let revOffset = MemoryLayout.offset(of: \task_vm_info_data_t.min_address) else {
            return nil
        }
        
        let taskVMInfoRevCount = mach_msg_type_number_t(revOffset / MemoryLayout<integer_t>.size)
        
        var info = task_vm_info_data_t()
        var count = taskVMInfoCount
        let result = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard result == KERN_SUCCESS, count >= taskVMInfoRevCount else {
            return nil
        }
        
        return info.phys_footprint
    }
    
    /// in bytes
    static var totalSystemMemory: UInt64? {
        return ProcessInfo().physicalMemory
    }
    
    /// in bytes
    static var availableSystemMemory: UInt64? {
        var size: mach_msg_type_number_t =
            UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let hostInfo = vm_statistics64_t.allocate(capacity: 1)
        
        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
        }
        guard result == KERN_SUCCESS else {
            return nil
        }
        
        let data = hostInfo.move()
        hostInfo.deallocate()
        let free = (UInt64(data.free_count) + UInt64(data.inactive_count)) * UInt64(vm_kernel_page_size)
        return free
    }
}
