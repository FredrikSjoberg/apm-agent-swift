//
//  ApmReporter.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal struct ApmServerConfiguration {
    
}

internal class ApmReporter: Reporter {
    
    private let encoderRepository: EncoderRepository
    private let eventQueue: EventQueue
    private let dispatcher: Dispatcher
    
    init(encoderRepository: EncoderRepository = ApmEncoderRepository(),
         eventQueue: EventQueue = ApmEventQueue(),
         dispatcher: Dispatcher = ApmEventDispatcher()) {
        self.encoderRepository = encoderRepository
        self.eventQueue = eventQueue
        self.dispatcher = dispatcher
    }
    
    func report(_ span: Span) {
        let encoderIdentifier = type(of: span.spanContext).encoderIdentifier
        do {
            let encoder = try encoderRepository.encoder(for: encoderIdentifier)
            let event = try encoder.encode(span)
            eventQueue.push(event)
        } catch {
            #warning("APM-TODO: Handle serialization error")
        }
    }
    
    func resume() {
        
    }
    
    func pause() {
        
    }
    
    func flush() {
        
    }
}
