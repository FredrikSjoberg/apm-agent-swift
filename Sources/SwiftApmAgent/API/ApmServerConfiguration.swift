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
    public let dispatchFrequency: Int
    
    init(serviceName: String,
         serverURL: URL,
         environment: String? = nil,
         dispatchFrequency: Int = 30) {
        self.serviceName = serviceName
        self.serverURL = serverURL
        self.environment = environment
        self.dispatchFrequency = dispatchFrequency
    }
    
    public var serviceVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
