//
//  ApmViewControllerPlugin.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//
import Foundation

#if !os(macOS)
import UIKit

@objc
class ApmViewControllerPlugin: NSObject, Plugin {
    static fileprivate let logger: Logger = LoggerFactory.getLogger(ApmViewControllerPlugin.self, .info)
    
    var excludedViewControllerBundles: Set<String> = [
        "com.apple"
    ]
    
    func configure() {
        UIViewController.apm_swizzleViewDidAppear()
        UIViewController.apm_wizzleViewWillDisappear()
        ScreenStack.excludedViewControllerBundles = excludedViewControllerBundles
    }
}
#endif
