//
//  ApmTimestampProvider.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmTimestampProvider: TimestampProvider {
    var epochNow: Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
}
