//
//  ApmEventQueue.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmEventQueue: EventQueue {
    
    private let lock = DispatchQueue(label: "com.swiftapmagent.core.reporter.eventqueue", attributes: .concurrent)
    private let queue = DispatchQueue(label: "com.swiftapmagent.core.reporter.eventqueue.dispatch")
    private var workItem: DispatchWorkItem?
    private var dispatchListener: ((ApmBatchEvent) -> Void)?
    private var dispatchNotificationListener: DispatchNotificationListener
    private let logger: Logger
    private var batch: ApmBatchEvent?
    
    init(dispatchFrequency: Int = 60,
         logger: Logger = LoggerFactory.getLogger(ApmEventQueue.self, .info),
         dispatchNotificationListener: DispatchNotificationListener = ApmDispatchNotificationListener()) {
        self.dispatchFrequency = dispatchFrequency
        self.logger = logger
        self.dispatchNotificationListener = dispatchNotificationListener
        
        self.dispatchNotificationListener.registerShouldFlushListener { [weak self] in
            self?.flush()
        }
        self.dispatchNotificationListener.registerShouldStartFlushListener { [weak self] in
            self?.startDispatchTimer()
        }
    }
    
    private func enqueue(_ event: Data) {
        if let current = batch {
            current.events.append(event)
        } else {
            batch = ApmBatchEvent(events: [event], status: .readyForDispatch)
        }
    }
    
    // MARK: Dispatch
    private func startDispatchTimer() {
        workItem?.cancel()
        
        let item = DispatchWorkItem(qos: .utility) { [weak self] in
            self?.flush()
        }
        
        queue.asyncAfter(deadline: .now() + .seconds(dispatchFrequency), execute: item)
        workItem = item
    }
    
    private func generateMetadataEvent() -> Data? {
        guard let serviceName = ApmAgent.shared().serverConfiguration?.serviceName else {
            logger.error("ServiceName not configured - unable to generate Metadata Event")
            return nil
        }
        do {
            let metadata = MetadataEvent(metadata: .init(process: nil,
                                                         system: nil,
                                                         service: generateMetadataService(serviceName: serviceName)))
            let metadataEncoder = JSONEncoder()
            metadataEncoder.keyEncodingStrategy = .convertToSnakeCase
            return try metadataEncoder.encode(metadata)
        } catch {
            logger.error("Failed to serialize Metadata Event")
            return nil
        }
    }
    
    private func generateMetadataService(serviceName: String) -> MetadataEvent.Metadata.Service {
        return .init(name: serviceName,
                     version: nil,
                     environment: nil,
                     agent: generateMetadataAgent(),
                     runtime: nil,
                     language: nil)
    }
    
    private func generateMetadataAgent() -> MetadataEvent.Metadata.Service.Agent {
        return .init(name: ApmAgent.shared().agentName,
                     version: ApmAgent.shared().agentVersion)
    }
    
    // MARK: <EventQueue>
    func push(_ event: Data) {
        lock.async(flags: .barrier) { [weak self] in
            self?.enqueue(event)
        }
    }
    
    func flush() {
        defer {
            startDispatchTimer()
        }
        guard let event = nextBatch else {
            return
        }
        guard let metadata = generateMetadataEvent() else {
            logger.error("Unable to generate Metadata Event")
            return
        }
        event.events.insert(metadata, at: 0)
        
        if dispatchListener == nil {
            logger.info("Flushing event queue with no event listener registered")
        }
        dispatchListener?(event)
    }
    
    var nextBatch: ApmBatchEvent? {
        var result: ApmBatchEvent?
        lock.sync {
            result = batch
            batch = nil
        }
        return result
    }
    
    var dispatchFrequency: Int
    
    func registerDispatchListener(_ request: @escaping (ApmBatchEvent) -> Void) {
        if dispatchListener != nil {
            logger.info("Only one dispatch listener is currently supported.")
            return
        }
        dispatchListener = request
        startDispatchTimer()
    }
}
