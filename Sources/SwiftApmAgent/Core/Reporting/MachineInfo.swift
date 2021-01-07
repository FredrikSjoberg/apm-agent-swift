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
}
