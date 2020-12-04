//
//  TimestampProvider.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

@objc
public protocol TimestampProvider {
    var epochNow: Int64 { get }
}