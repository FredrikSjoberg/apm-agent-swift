//
//  ApmUserSessionPlugin.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-08.
//

import Foundation

#if !os(macOS)
import UIKit

class ApmUserSessionPlugin: Plugin {
    internal static let logger: Logger = LoggerFactory.getLogger(ApmUserSessionPlugin.self, .info)
    
    func configure() { }
    
    var intakeEncoders: [String : () -> EventEncoder] {
        return [:]
    }
    
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] notification in
            self?.startUserSession(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] notification in
            self?.endUserSession(notification: notification)
        }
    }
    
    // MARK: Handle Notifications
    private func startUserSession(notification: Notification) {
        ApmUserSessionPlugin.logger.debug("Activating Transaction: User Session")
        let transaction = ApmAgent.shared().tracer.startRootTransaction(name: "User Session", type: "user-session")
        transaction.activate()
    }
    
    private func endUserSession(notification: Notification) {
        ApmUserSessionPlugin.logger.debug("Deactivating Transaction: User Session")
        let transaction = ApmAgent.shared().tracer.currentTransaction()
        transaction?.deactivate()
        transaction?.end()
    }
}
#endif
