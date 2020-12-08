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
        
        guard ScreenStack.shared.shouldMonitor(self) else {
            return
        }
        
        guard let plugin = ApmAgent.shared().plugin(ApmViewControllerPlugin.self) else {
            ApmViewControllerPlugin.logger.error("Plugin not found")
            return
        }
        
        switch plugin.traceMode {
        case .transaction:
            traceViewDidAppearTransaction()
        case .span:
            traceViewDidAppearSpan()
        }
        
        apmViewDidAppear(animated)
    }
    
    @objc
    func apmViewWillDisappear(_ animated: Bool) {
        defer {
            apmBridgedViewWillDisappear(animated)
        }
        
        guard ScreenStack.shared.shouldMonitor(self) else {
            return
        }
        
        guard let plugin = ApmAgent.shared().plugin(ApmViewControllerPlugin.self) else {
            ApmViewControllerPlugin.logger.error("Plugin not found")
            return
        }
        
        if plugin.traceMode == .span {
            traceViewWillDisappear()
        }
    }
    
    private func apmBridgedViewWillDisappear(_ animated: Bool) {
        apmViewWillDisappear(animated)
    }
    
    // MARK: Trace Management
    private func traceViewDidAppearTransaction() {
        if let _ = ScreenStack.shared.pop(self) {
            ApmViewControllerPlugin.logger.debug("Deactivating Transaction: \(screenName)")
            let transaction = ApmAgent.shared().tracer.currentTransaction()
            transaction?.deactivate()
            transaction?.end()
        }
        
        if let _ = ScreenStack.shared.push(self) {
            ApmViewControllerPlugin.logger.debug("Activating Transaction: \(screenName)")
            let transaction = ApmAgent.shared().tracer.startRootTransaction(name: screenName, type: "screen-view")
            transaction.activate()
        }
    }
    
    private func traceViewDidAppearSpan() {
        ApmViewControllerPlugin.logger.debug("Activating Span: \(screenName)")
        let parent = ApmAgent.shared().tracer.getActive()
        let span = parent?.createSpan(name: screenName, type: "screen-view")
        associateSpan(span)
        span?.activate()
    }
    
    private func traceViewWillDisappear() {
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
