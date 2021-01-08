//
//  ApmViewControllerPlugin.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//
import Foundation

#if !os(macOS)
import UIKit

public class ApmViewControllerPlugin: NSObject, Plugin {
    internal static let logger: Logger = LoggerFactory.getLogger(ApmViewControllerPlugin.self)
    
    public var excludedViewControllerBundles: Set<String> = [
        "com.apple"
    ]
    
    public enum TraceMode {
        /// Creates a new root transaction for each view that appears, deactivating and ending the previously active transaction
        case transaction
        
        /// Creates a child transaction for each new view that appears if an active root transaction exists. Otherwise, creates a new root transaction.
        case childTransaction
        
        /// Creates a span for each new view that appears if an active root transaction exists.
        case span
    }
    
    public var traceMode: TraceMode = .childTransaction
    
    public var intakeEncoders: [String : () -> EventEncoder] {
        return [:]
    }
    
    public func configure() {
        UIViewController.apm_swizzleViewDidAppear()
        UIViewController.apm_wizzleViewWillDisappear()
        ScreenStack.excludedViewControllerBundles = excludedViewControllerBundles
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] notification in
            self?.handleDidBecomeActive(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] notification in
            self?.handleWillResignActive(notification: notification)
        }
    }
    
    private func handleDidBecomeActive(notification: Notification) {
        ScreenStack.shared.lastActiveViewController?.traceViewDidAppear()
    }
    
    private func handleWillResignActive(notification: Notification) {
        ScreenStack.shared.lastActiveViewController?.traceViewWillDisappear()
    }
}
#endif
