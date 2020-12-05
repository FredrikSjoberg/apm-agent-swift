//
//  HttpClient.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal protocol HttpClient {
    func send(_ request: URLRequest)
}
