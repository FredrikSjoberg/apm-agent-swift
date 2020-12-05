//
//  ApmServerConfiguration.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

public class ApmServerConfiguration {
    public let serverURL: URL
    
    init(serverURL: URL) {
        self.serverURL = serverURL
    }
}
