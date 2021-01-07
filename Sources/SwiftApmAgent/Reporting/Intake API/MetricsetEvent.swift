//
//  MetricsetEvent.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-07.
//

import Foundation

struct MetricsetEvent: ReporterEvent {
    
    /// Data captured by an agent representing an event occurring in a monitored service
    let metricset: Metricset
    
    /// Version: https://github.com/elastic/apm-server/blob/v7.10.1/docs/spec/metricsets/metricset.json
    struct Metricset: Encodable {
        
        /// Recorded time of the event, UTC based and formatted as microseconds since Unix epoch
        let timestamp: Int64
        
        /// Sampled application metrics collected from the agent
        let samples: [String: Sample]
        
        /// A single metric sample.
        ///
        /// Version: https://github.com/elastic/apm-server/blob/v7.10.1/docs/spec/metricsets/sample.json
        struct Sample: Encodable {
            let value: Value
            
            enum Value {
                case double(Double)
                case integer64(Int64)
                case uinteger64(UInt64)
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: Key.self)
                switch value {
                case .double(let val): try container.encode(val, forKey: .value)
                case .integer64(let val): try container.encode(val, forKey: .value)
                case .uinteger64(let val): try container.encode(val, forKey: .value)
                }
            }
            
            enum Key: CodingKey {
                case value
            }
        }
    }
}
