//
//  IdProvider.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

public protocol IdProvider {
    func generateId() -> String
    func generateTraceId() -> String
}
