//
//  ApmEventDispatcher.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmEventDispatcher: Dispatcher {
    private let intakePath: String = "intake/v2/events"
    private let httpClient: HttpClient
    private let logger: Logger
    private let newline = "\n".data(using: .utf8)
    
    init(httpClient: HttpClient = ApmHttpClient(),
         logger: Logger = LoggerFactory.getLogger(ApmEventDispatcher.self, .info)) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    private func urlRequest(_ batchEvent: ApmBatchEvent) -> URLRequest? {
        guard let serverURL = ApmAgent.shared().serverConfiguration?.serverURL else {
            logger.error("Apm serverURL not configured")
            return nil
        }
        let intakeURL = serverURL.appendingPathComponent(intakePath)
        var request = URLRequest(url: intakeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-ndjson", forHTTPHeaderField: "Content-Type")
        request.httpBody = newLineDelimitedJson(batchEvent.events)
        return request
        return request
    }
    
    private func newLineDelimitedJson(_ data: [Data]) -> Data? {
        guard let newline = newline else {
            fatalError("Failed to produce newline delimiter for data join")
        }
        return Data(data.joined(separator: newline))
    }
    
    // MARK: <Dispatcher>
    func post(_ batchEvent: ApmBatchEvent) {
        guard let request = urlRequest(batchEvent) else {
            logger.info("Unable to create request for event")
            return
        }
        httpClient.send(request)
    }
}
