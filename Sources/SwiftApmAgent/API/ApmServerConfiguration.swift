//
//  ApmServerConfiguration.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

public class ApmServerConfiguration {
    public let serviceName: String
    public let serverURL: URL
    
    init(serviceName: String,
         serverURL: URL) {
        self.serviceName = serviceName
        self.serverURL = serverURL
    }
}
