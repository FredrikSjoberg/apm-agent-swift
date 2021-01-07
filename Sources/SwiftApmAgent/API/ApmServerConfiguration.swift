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
    public let environment: String?
    
    init(serviceName: String,
         serverURL: URL,
         environment: String? = nil) {
        self.serviceName = serviceName
        self.serverURL = serverURL
        self.environment = environment
    }
    
    public var serviceVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
