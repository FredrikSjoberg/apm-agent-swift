//
//  ApmEventDispatcher.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmEventDispatcher: Dispatcher {
    private let httpClient: HttpClient
    private let logger: Logger
    private let newline = "\n".data(using: .utf8)
    
    init(httpClient: HttpClient = ApmHttpClient(),
         logger: Logger = LoggerFactory.getLogger(ApmEventDispatcher.self, .info)) {
        self.httpClient = httpClient
        self.logger = logger
    }
    
    private func urlRequest(_ batchEvent: ApmBatchEvent) -> URLRequest? {
        guard let url = ApmAgent.shared().serverConfiguration?.serverURL else {
            logger.error("Apm serverURL not configured")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpBody = newLineDelimitedJson(batchEvent.events)
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
