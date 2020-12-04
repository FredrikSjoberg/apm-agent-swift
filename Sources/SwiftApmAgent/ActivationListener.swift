//
//  ActivationListener.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal protocol ActivationListener: AnyObject {
    func beforeActivate(_ span: Span)
    func afterDeactivate(_ span: Span)
}
