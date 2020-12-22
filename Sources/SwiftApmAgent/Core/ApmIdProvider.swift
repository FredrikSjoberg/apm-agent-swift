//
//  ApmIdProvider.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-04.
//

import Foundation

internal class ApmIdProvider: IdProvider {
    private func genId(_ count: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        guard status == errSecSuccess else {
            return [UInt8](repeating: 0, count: count)
        }
        return bytes
    }
    
    func generate64BitId() -> IdRepresentation {
        return ApmId(genId(8))
    }
    
    func generate128BitId() -> IdRepresentation {
        return ApmId(genId(16))
    }
}
