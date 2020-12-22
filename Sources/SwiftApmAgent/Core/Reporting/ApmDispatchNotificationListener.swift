//
//  ApmNotificationListener.swift
//
//
//  Created by Fredrik Sjöberg on 2020-12-08.
//

import Foundation

#if !os(macOS)
import UIKit

class ApmDispatchNotificationListener: DispatchNotificationListener {
    var shouldFlushListener: (() -> Void)?
    var shouldStartFlushListener: (() -> Void)?
    init() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.shouldFlushListener?()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.shouldStartFlushListener?()
        }
    }
    
    func registerShouldFlushListener(callback: @escaping () -> Void) {
        shouldFlushListener = callback
    }
    
    func registerShouldStartFlushListener(callback: @escaping () -> Void) {
        shouldStartFlushListener = callback
    }
}

#else

class ApmDispatchNotificationListener: DispatchNotificationListener {
    func registerShouldFlushListener(callback: @escaping () -> Void) {
        
    }
}
#endif
