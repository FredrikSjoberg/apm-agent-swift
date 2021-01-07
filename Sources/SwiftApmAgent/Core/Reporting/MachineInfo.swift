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
    
    static var pid: Int {
        return Int(ProcessInfo().processIdentifier)
    }
    
    static var processName: String {
        return ProcessInfo().processName
    }
    
    static var processArguments: [String] {
        return ProcessInfo().arguments
    }
    
    static var machine: String {
        #if os(iOS) && !arch(x86_64) && !arch(i386)
        return sysctl(hwModel)
        #else
        return sysctl(hwMachine)
        #endif
    }

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
}
