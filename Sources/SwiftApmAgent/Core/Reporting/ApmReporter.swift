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
         logger: Logger = LoggerFactory.getLogger(ApmReporter.self, .info)) {
        self.encoderRepository = encoderRepository
        self.eventQueue = eventQueue
        self.dispatcher = dispatcher
        self.logger = logger
        
        self.eventQueue.registerDispatchListener { [weak self] event in
            self?.dispatcher.post(event)
        }
    }
    
    func register(intakeEncoders: [String: () -> IntakeEncoder]) {
        encoderRepository.register(intakeEncoders: intakeEncoders)
    }
    
    func report(_ span: Span) {
        let encoderIdentifier = type(of: span.spanContext).encoderIdentifier
        do {
            let encoder = try encoderRepository.encoder(for: encoderIdentifier)
            let event = try encoder.encode(span)
            eventQueue.push(event)
        } catch {
            logger.error("Failed to encode span with span.id=\(span.id). Error: \(error)")
        }
    }
}
