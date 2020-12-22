//
//  ApmId.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

private extension Sequence where Element == UInt8 {
    func toHexString() -> String {
        return map {
            String(format: "%02hhx", $0)
        }
        .joined(separator: "")
    }
}

struct ApmId: IdRepresentation {
    let bytes: [UInt8]
    let data: Data
    let hexString: String
    
    init(_ bytes: [UInt8]) {
        self.bytes = bytes
        self.data = Data(bytes)
        self.hexString = bytes.toHexString()
    }
}
