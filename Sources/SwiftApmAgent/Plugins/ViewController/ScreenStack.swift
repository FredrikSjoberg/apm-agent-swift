//
//  ScreenStack.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-05.
//

import Foundation

#if !os(macOS)
import UIKit

internal class ScreenStack {
    static var excludedViewControllerBundles: Set<String> = []
    
    /// Records presented ViewController to enable correct screen-view tracking when app resigns/regains active status  (ie willResignActiveNotification/didBecomeActiveNotification)
    var lastActiveViewController: UIViewController?
    
    static let shared = ScreenStack()
    
    private var stack: [String] = []
    private let logger: Logger
    
    init(logger: Logger = LoggerFactory.getLogger(ScreenStack.self)) {
        self.logger = logger
    }
    
    internal func shouldMonitor(_ viewController: UIViewController) -> Bool {
        let bundle = Bundle(for: type(of: viewController))
        guard let bundleIdentifier = bundle.bundleIdentifier else {
            logger.error("No bundleIdentifier for ViewController: \(viewController.screenName)")
            return false
        }
        
        guard !ScreenStack.excludedViewControllerBundles.contains(where: {
            bundleIdentifier.hasPrefix($0)
        }) else {
            logger.debug("ViewController is excluded: \(viewController.screenName)")
            return false
        }
        
        guard viewController.children.isEmpty else {
            logger.debug("ViewController has children: \(viewController.screenName)")
            return false
        }
        
        return true
    }
    
    func push(_ viewController: UIViewController) -> String? {
        guard shouldMonitor(viewController) else {
            logger.debug("Ignoring push of untracked ViewController: \(viewController.screenName)")
            return nil
        }
        
        logger.debug("Pushing ViewController \(viewController.screenName)")
        stack.append(viewController.screenName)
        return viewController.screenName
    }
    
    func pop(_ viewController: UIViewController) -> String? {
        guard shouldMonitor(viewController) else {
            logger.debug("Ignoring pop of untracked ViewController: \(viewController.screenName)")
            return nil
        }
        guard let top = stack.last else {
            logger.error("Unable to pop ViewController \(viewController.screenName), stack is empty!")
            return nil
        }
        let screenName = viewController.screenName
        guard top == screenName else {
            logger.info("ViewController pop failed: expected \(screenName), found \(top)")
            return nil
        }
        return stack.removeLast()
    }
    
    func peek() -> String? {
        return stack.last
    }
}
#endif
