//
//  ApmErrorCaptureEncoder.swift
//  
//
//  Created by Fredrik Sjöberg on 2021-01-04.
//

import Foundation

internal class ApmErrorCaptureEncoder: EventEncoder {
    enum Error: Swift.Error {
        case unsupportedSpanContext(Span)
        case unsupportedEventType(Span)
    }
    
    private let jsonEncoder: JSONEncoder

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }
    
    func encode(_ event: Event) throws -> Data {
        guard let errorCapture = event as? ErrorCapture else {
            throw ApmEncodingError.unsupportedEventType(event)
        }
        guard let context = errorCapture.eventContext as? ApmErrorCaptureContext else {
            throw ApmEncodingError.unsupportedEventContext(event)
        }
        let intakeEvent = errorEvent(errorCapture: errorCapture, context: context)
        return try jsonEncoder.encode(intakeEvent)
    }
    
    private func errorEvent(errorCapture: ErrorCapture, context: ApmErrorCaptureContext) -> ErrorEvent {
        let event = ErrorEvent.Error(timestamp: errorCapture.timestamp,
                                     id: errorCapture.id.hexString,
                                     transactionId: errorCapture.traceContext.transactionId.hexString,
                                     traceId: errorCapture.traceContext.traceId.hexString,
                                     parentId: errorCapture.traceContext.parentId?.hexString ?? errorCapture.traceContext.transactionId.hexString,
                                     transaction: nil,
                                     context: nil,
                                     culprit: nil,
                                     exception: exception(context: context),
                                     log: [])
        return .init(error: event)
    }
    
    private func exception(context: ApmErrorCaptureContext) -> ErrorEvent.Error.Exception? {
        let code = errorCode(context.error)
        let message = errorMessage(context.error)
        let domain = errorDomain(context.error)
        
        guard code != nil || message != nil || domain != nil else {
            return nil
        }
        
        return .init(code: code,
                     message: message,
                     module: domain,
                     stacktrace: [],
                     type: nil,
                     handled: nil)
    }
    
    private func errorCode(_ error: Swift.Error) -> Int? {
        return (error as NSError).code
    }
    
    private func errorMessage(_ error: Swift.Error) -> String? {
        return (error as NSError).debugDescription
    }
    
    private func errorDomain(_ error: Swift.Error) -> String? {
        return (error as NSError).domain
    }
}
