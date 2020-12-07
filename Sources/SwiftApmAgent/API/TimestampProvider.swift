//
//  TimestampProvider.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

public protocol TimestampProvider {
    /// Timestamp in unix epoch time as microseconds
    var epochNow: Int64 { get }
}
