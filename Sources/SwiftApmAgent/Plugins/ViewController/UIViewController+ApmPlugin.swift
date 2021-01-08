//
//  UIViewController+ApmPlugin.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

#if !os(macOS)
import UIKit

internal extension UIViewController {
    
    var screenName: String {
        return String(describing: type(of: self))
    }
    
    // MARK: Method swizzling
    static func apm_swizzleViewDidAppear() {
        
        let selector = #selector(UIViewController.viewDidAppear(_:))
        let apmSelector = #selector(UIViewController.apmViewDidAppear(_:))
        
        guard let method1 = class_getInstanceMethod(UIViewController.self, selector),
              let method2 = class_getInstanceMethod(UIViewController.self, apmSelector) else {
            return
        }
        
        method_exchangeImplementations(method1, method2)
    }
    
    static func apm_wizzleViewWillDisappear() {
        
        let selector = #selector(UIViewController.viewWillDisappear(_:))
        let apmSelector = #selector(UIViewController.apmViewWillDisappear(_:))
        
        guard let method1 = class_getInstanceMethod(UIViewController.self, selector),
              let method2 = class_getInstanceMethod(UIViewController.self, apmSelector) else {
            return
        }
        
        method_exchangeImplementations(method1, method2)
    }
    
    // MARK: ViewController life cycle
    @objc
    func apmViewDidAppear(_ animated: Bool) {
        apmBridgedViewDidAppear(animated)
    }
    
    private func apmBridgedViewDidAppear(_ animated: Bool) {
        defer {
            apmViewDidAppear(animated)
        }
        
        traceViewDidAppear()
    }
    
    @objc
    func apmViewWillDisappear(_ animated: Bool) {
        defer {
            apmBridgedViewWillDisappear(animated)
        }
        
        traceViewWillDisappear()
    }
    
    private func apmBridgedViewWillDisappear(_ animated: Bool) {
        apmViewWillDisappear(animated)
    }
    
    // MARK: Trace Management
    
    func traceViewDidAppear() {
        guard ScreenStack.shared.shouldMonitor(self) else {
            return
        }
        
        guard let plugin = ApmAgent.shared().plugin(ApmViewControllerPlugin.self) else {
            ApmViewControllerPlugin.logger.error("Plugin not found")
            return
        }
        
        ScreenStack.shared.lastActiveViewController = self
        
        switch plugin.traceMode {
        case .transaction:
            activateViewAsRootTransaction()
        case .childTransaction:
            activateViewAssociationAsTransaction()
        case .span:
            activateViewAssociationAsSpan()
        }
    }
    
    func traceViewWillDisappear() {
        guard ScreenStack.shared.shouldMonitor(self) else {
            return
        }
        
        guard let plugin = ApmAgent.shared().plugin(ApmViewControllerPlugin.self) else {
            ApmViewControllerPlugin.logger.error("Plugin not found")
            return
        }
        
        switch plugin.traceMode {
        case .span, .childTransaction:
            deactivateViewAssociation()
        case .transaction:
            break
        }
    }
    
    private func activateViewAsRootTransaction() {
        if ScreenStack.shared.pop(self) != nil {
            ApmViewControllerPlugin.logger.debug("Deactivating Transaction: \(screenName)")
            let transaction = ApmAgent.shared().tracer.currentTransaction()
            transaction?.deactivate()
            transaction?.end()
        }
        
        if ScreenStack.shared.push(self) != nil {
            ApmViewControllerPlugin.logger.debug("Activating Transaction: \(screenName)")
            let transaction = ApmAgent.shared().tracer.startRootTransaction(name: screenName, type: "screen-view")
            transaction.activate()
        }
    }
    
    private func activateViewAssociationAsTransaction() {
        ApmViewControllerPlugin.logger.debug("Activating Transaction: \(screenName)")
        let transaction = ApmAgent.shared().tracer.startTransaction(name: screenName, type: "screen-view")
        associateSpan(transaction)
        transaction.activate()
    }
    
    private func activateViewAssociationAsSpan() {
        ApmViewControllerPlugin.logger.debug("Activating Span: \(screenName)")
        let parent = ApmAgent.shared().tracer.getActive()
        let span = parent?.createSpan(name: screenName, type: "screen-view")
        associateSpan(span)
        span?.activate()
    }
    
    private func deactivateViewAssociation() {
        ApmViewControllerPlugin.logger.debug("Deactivating Span: \(screenName)")
        let span = getAssociatedSpan()
        span?.deactivate()
        span?.end()
    }
    
    // MARK: Object Association
    private struct AssociatedKeys {
        static var span: UInt8 = 0
    }
    
    private func associateSpan(_ span: Span?) {
        if let span = span {
            objc_setAssociatedObject(self, &AssociatedKeys.span, span, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func getAssociatedSpan() -> Span? {
        let span = objc_getAssociatedObject(self, &AssociatedKeys.span) as? Span
        if let span = span {
            objc_removeAssociatedObjects(span)
        }
        return span
    }
}
#endif
