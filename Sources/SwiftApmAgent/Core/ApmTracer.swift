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
    
    init(reporter: Reporter = ApmReporter(),
         idProvider: IdProvider = ApmIdProvider(),
         timestampProvider: TimestampProvider = ApmTimestampProvider()) {
        self.reporter = reporter
        self.idProvider = idProvider
        self.timestampProvider = timestampProvider
    }
    
    // MARK: Transaction
    func startRootTransaction(name: String, type: String) -> Transaction {
        let context = ApmTraceContext(traceId: idProvider.generateTraceId(),
                                      transactionId: idProvider.generateId())
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
            return startRootTransaction(name: name, type: type)
        }
    }
    
    func endSpan(_ span: Span) {
        reporter.report(span)
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
                if activeSpans[active!.id] != nil {
                    break
                } else {
                    active = activeSpanQueue.popLast()
                }
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
            
            self?.activeSpans[span.id] = span
            self?.activeSpanQueue.append(span)
            if let transaction = span as? Transaction {
                self?.activeTransaction = transaction
            }
            DispatchQueue.main.async {
                print("-+ Activating Span")
                print(span)
            }
        }
    }
    
    func deactivate(_ span: Span) {
        lock.async(flags: .barrier) { [weak self] in
            guard let active = self?.activeSpans[span.id], active.id == span.id else {
                #warning("APM-TODO: Log warning - deactivating span that is not active")
                return
            }
            
            self?.activeSpans[span.id] = nil
            if let transaction = span as? Transaction, transaction.id == span.id {
                self?.activeTransaction = nil
            }
            DispatchQueue.main.async {
                print("-+ Deactivating Span")
                print(span)
            }
            
            self?.activationListeners.forEach { listener in
                listener.afterDeactivate(span)
            }
        }
    }
}
