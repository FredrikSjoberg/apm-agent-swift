//
//  MetadataEvent.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

struct MetadataEvent: ReporterEvent {
    /// Metadata concerning the other objects in the stream.
    let metadata: Metadata
    
    /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/metadata.json
    struct Metadata: Encodable {
        /// Process information
        let process: Process?
        
        /// System properties describing the system running this service
        let system: System?
        
        /// Service description
        let service: Service
        
        /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/process.json
        struct Process: Encodable {
            /// Process ID of the service
            let pid: Int
            
            /// Process runtime title
            let title: String?
            
            /// Parent process ID of the service
            let ppid: Int?
            
            /// Command line arguments used to start this process
            let argv: [String]
        }
        
        /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/system.json
        struct System: Encodable {
            /// Architecture of the system the agent is running on.
            ///
            /// Example: arm64
            let architecture: String?
            
            /// Hostname of the host the monitored service is running on. It normally contains what the hostname command returns on the host machine.
            ///
            /// Will be ignored if kubernetes information is set, otherwise should always be set.
            let detectedHostName: String?
            
            /// Name of the system platform the agent is running on.
            ///
            /// Example: iOS
            let platform: String?
        }
        
        /// Version: https://github.com/elastic/apm-server/blob/v7.10.0/docs/spec/service.json
        struct Service: Encodable {
            /// Immutable name of the service emitting this event
            let name: String
            
            /// Version of the service emitting this event
            let version: String?
            
            /// Environment name of the service, e.g. 'production', 'staging' or ...
            let environment: String?
            
            // Name and version of the Elastic APM agent
            let agent: Agent
            
            /// Name and version of the language runtime running this service
            let runtime: Runtime?
            
            /// Name and version of the programming language used
            let language: Language?
            
            struct Agent: Encodable {
                /// Name of the Elastic APM agent, e.g 'SwiftApmAgent'
                let name: String
                
                /// Version of the Elastic APM agent, e.g. '1.0.0'
                let version: String
            }
            
            struct Runtime: Encodable {
                /// Name of the language runtime using this service
                let name: String?
                
                    /// Version of the language runtime using this service
                let version: String?
            }
            
            struct Language: Encodable {
                /// Name of the language used for this service
                let name: String?
                
                /// Version of the language used for this service
                let version: String?
            }
        }
    }
}
