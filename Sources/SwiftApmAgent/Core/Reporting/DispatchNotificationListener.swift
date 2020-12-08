//
//  DispatchNotificationListener.swift
//  
//
//  Created by Fredrik Sjöberg on 2020-12-08.
//

import Foundation

protocol DispatchNotificationListener {
    func registerShouldFlushListener(callback: @escaping () -> Void)
    func registerShouldStartFlushListener(callback: @escaping () -> Void)
}
