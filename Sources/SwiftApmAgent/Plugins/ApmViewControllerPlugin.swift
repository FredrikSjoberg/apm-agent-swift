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
    internal static let logger: Logger = LoggerFactory.getLogger(ApmViewControllerPlugin.self, .info)
    
    public var excludedViewControllerBundles: Set<String> = [
        "com.apple"
    ]
    
    public enum TraceMode {
        case transaction
        case span
    }
    
    public var traceMode: TraceMode = .transaction
    
    public var intakeEncoders: [String : () -> IntakeEncoder] {
        return [:]
    }
    
    public func configure() {
        UIViewController.apm_swizzleViewDidAppear()
        UIViewController.apm_wizzleViewWillDisappear()
        ScreenStack.excludedViewControllerBundles = excludedViewControllerBundles
    }
}
#endif
