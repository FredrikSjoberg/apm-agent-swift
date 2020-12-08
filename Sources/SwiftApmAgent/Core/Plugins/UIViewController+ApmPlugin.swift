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
        
        apmViewDidAppear(animated)
    }
    
    @objc
    func apmViewWillDisappear(_ animated: Bool) {
        apmBridgedViewWillDisappear(animated)
    }
    
    private func apmBridgedViewWillDisappear(_ animated: Bool) {
        apmViewWillDisappear(animated)
    }
}
#endif
