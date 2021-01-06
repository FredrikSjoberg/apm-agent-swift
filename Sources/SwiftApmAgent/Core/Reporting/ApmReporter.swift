//
//  ApmReporter.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmReporter: Reporter {
    
    private let encoderRepository: EncoderRepository
    private let eventQueue: EventQueue
    private let dispatcher: Dispatcher
    private let logger: Logger
    
    init(encoderRepository: EncoderRepository = ApmEncoderRepository(),
         eventQueue: EventQueue = ApmEventQueue(),
         dispatcher: Dispatcher = ApmEventDispatcher(),
         logger: Logger = LoggerFactory.getLogger(ApmReporter.self)) {
        self.encoderRepository = encoderRepository
        self.eventQueue = eventQueue
        self.dispatcher = dispatcher
        self.logger = logger
        
        self.eventQueue.registerDispatchListener { [weak self] event in
            self?.dispatcher.post(event)
        }
    }
    
    func register(intakeEncoders: [String: () -> EventEncoder]) {
        encoderRepository.register(intakeEncoders: intakeEncoders)
    }
    
    func report(_ event: Event) {
        let encoderIdentifier = type(of: event.eventContext).encoderIdentifier
        do {
            logger.debug("Preparing encode event for dispatch \n \(event)")
            let encoder = try encoderRepository.encoder(for: encoderIdentifier)
            let event = try encoder.encode(event)
            eventQueue.push(event)
        } catch {
            logger.error("Failed to encode event with event.id=\(event.id). Error: \(error)")
        }
    }
}
