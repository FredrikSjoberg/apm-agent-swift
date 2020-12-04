//
//  ApmEventDispatcher.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmEventDispatcher: Dispatcher {
    private let httpClient: HttpClient
    private var workItem: DispatchWorkItem?
    
    init(httpClient: HttpClient = ApmHttpClient(),
         dispatchFrequency: TimeInterval = 60) {
        self.httpClient = httpClient
        self.dispatchFrequency = dispatchFrequency
    }
    
    // MARK: <Dispatcher>
    var dispatchFrequency: TimeInterval
    
    func start() {
        
    }
}
