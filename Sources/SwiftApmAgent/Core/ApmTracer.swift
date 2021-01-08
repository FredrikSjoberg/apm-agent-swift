//
//  ApmTracer.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmTracer: Tracer {
    
    private let reporter: Reporter
    private let idProvider: IdProvider
    private let timestampProvider: TimestampProvider
    private let logger: Logger
    
    init(reporter: Reporter = ApmReporter(),
         idProvider: IdProvider = ApmIdProvider(),
         timestampProvider: TimestampProvider = ApmTimestampProvider(),
         logger: Logger = LoggerFactory.getLogger(ApmTracer.self)) {
        self.reporter = reporter
        self.idProvider = idProvider
        self.timestampProvider = timestampProvider
        self.logger = logger
    }
    
    func register(intakeEncoders: [String: () -> EventEncoder]) {
        (reporter as? ApmReporter)?.register(intakeEncoders: intakeEncoders)
    }
    
    // MARK: Transaction
    func startTransaction(name: String, type: String) -> Transaction {
        if let parent = currentTransaction() {
            let context = ApmTraceContext(traceId: parent.traceContext.traceId,
                                          transactionId: idProvider.generate64BitId(),
                                          parentId: parent.id,
                                          serviceName: parent.traceContext.serviceName)
            let transaction = ApmTransaction(name: name,
                                             type: type,
                                             tracer: self,
                                             traceContext: context,
                                             timestampProvider: timestampProvider)
            return transaction
        } else {
            return startRootTransaction(name: name, type: type)
        }
    }
    
    func startRootTransaction(name: String, type: String) -> Transaction {
        if let activeTransaction = currentTransaction() {
            logger.debug("Deactivating currently active transaction with transaction.id=\(activeTransaction.id) before starting new root transaction")
            activeTransaction.deactivate()
            activeTransaction.end()
        }
        let context = ApmTraceContext(traceId: idProvider.generate128BitId(),
                                      transactionId: idProvider.generate64BitId())
        let transaction = ApmTransaction(name: name,
                                         type: type,
                                         tracer: self,
                                         traceContext: context,
                                         timestampProvider: timestampProvider)
        return transaction
    }
    
    func endTransaction(_ transaction: Transaction) {
        reporter.report(transaction)
    }
    
    // MARK: Span
    func startSpan(name: String, type: String) -> Span {
        if let parent = getActive() {
            let context = parent.traceContext.createChild(parentId: parent.id)
            let span = ApmSpan(name: name,
                               type: type,
                               tracer: self,
                               traceContext: context,
                               timestampProvider: timestampProvider)
            return span
        } else {
            logger.debug("No active transaction to spawn spans. Creating new root transaction")
            return startRootTransaction(name: name, type: type)
        }
    }
    
    func endSpan(_ span: Span) {
        reporter.report(span)
    }
    
    // MARK: Capture error
    func captureError(_ error: Error) -> ErrorCapture? {
        if let parent = getActive() {
            let context = parent.traceContext.createChild(parentId: parent.id)
            let errorCapture = ApmErrorCapture(tracer: self,
                                               traceContext: context,
                                               eventContext: ApmErrorCaptureContext(error: error),
                                               timestampProvider: timestampProvider,
                                               idProvider: idProvider)
            return errorCapture
        } else {
            logger.info("No active transaction to base error on. error=\(error.localizedDescription)")
            return nil
        }
    }
    
    func reportError(_ error: ErrorCapture) {
        reporter.report(error)
    }
    
    // MARK: Metricset
    func createMetricSet() -> MetricSet? {
        if let parent = getActive() {
            let context = parent.traceContext.createChild(parentId: parent.id)
            
            let metricSet = ApmMetricSet(tracer: self,
                                         traceContext: context,
                                         timestampProvider: timestampProvider,
                                         idProvider: idProvider)
            return metricSet
        } else {
            logger.info("No active transaction to base metricset on.")
            return nil
        }
    }
    
    func reportMetricSet(_ metricSet: MetricSet) {
        reporter.report(metricSet)
    }
    
    // MARK: Status
    private var activeSpans: [String: Span] = [:]
    private var activeTransaction: Transaction?
    private var activeSpanQueue: [Span] = []
    private var activationListeners: [ActivationListener] = []
    
    private let lock = DispatchQueue(label: "com.swiftapmagent.core.tracer.queue", attributes: .concurrent)
    
    func currentTransaction() -> Transaction? {
        var active: Transaction?
        lock.sync {
            active = activeTransaction
        }
        return active
    }
    
    func getActive() -> Span? {
        var active: Span?
        lock.sync {
            active = activeSpanQueue.last
            while active != nil {
                if let active = active, activeSpans[active.id.hexString] != nil {
                    break
                } else {
                    active = activeSpanQueue.popLast()
                }
            }
            if active == nil {
                active = activeTransaction
            }
        }
        return active
    }
    
    func getActiveSpan() -> Span? {
        return getActive()
    }
    
    func activate(_ span: Span) {
        lock.async(flags: .barrier) { [weak self] in
            self?.activationListeners.forEach { listener in
                listener.beforeActivate(span)
            }
            
            self?.activeSpans[span.id.hexString] = span
            self?.activeSpanQueue.append(span)
            if let transaction = span as? Transaction,
               (transaction.traceContext.parentId == nil || self?.activeTransaction == nil) {
                self?.activeTransaction = transaction
            }
            self?.logger.debug("Activating Span \n \(span)")
        }
    }
    
    func deactivate(_ span: Span) {
        lock.async(flags: .barrier) { [weak self] in
            guard let active = self?.activeSpans[span.id.hexString], active.id.hexString == span.id.hexString else {
                self?.logger.error("Deactivating inactive span {\(span.id)}")
                return
            }
            
            self?.activeSpans[span.id.hexString] = nil
            if let transaction = span as? Transaction,
               let activeTransaction = self?.activeTransaction,
               transaction.id.hexString == activeTransaction.id.hexString {
                self?.activeTransaction = nil
            }
            self?.logger.debug("Deactivating Span \n \(span)")
            
            self?.activationListeners.forEach { listener in
                listener.afterDeactivate(span)
            }
        }
    }
}
