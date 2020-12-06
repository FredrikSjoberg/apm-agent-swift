//
//  ApmHttpClient.swift
//
//
//  Created by Fredrik Sjöberg on 2020-11-29.
//

import Foundation

internal class ApmHttpClient: HttpClient {
    private static var defaultURLSession: URLSession = {
        let configuration = URLSessionConfiguration()
        return URLSession(configuration: configuration)
    }()
    
    private let urlSession: URLSession
    private let logger: Logger
    
    init(urlSession: URLSession = ApmHttpClient.defaultURLSession,
         logger: Logger = LoggerFactory.getLogger(ApmHttpClient.self, .info)) {
        self.urlSession = urlSession
        self.logger = logger
    }
    
    func send(_ request: URLRequest) {
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                self?.logger.error("dataTask returned invalid response type")
                return
            }
            guard httpResponse.statusCode >= 200, httpResponse.statusCode <= 300 else {
                self?.handleHttpFailure(httpResponse, error)
                return
            }
            self?.handleHttpSuccess(httpResponse, data)
        }
        .resume()
    }
    
    private func handleHttpSuccess(_ urlResponse: HTTPURLResponse, _ data: Data?) {
        logger.debug("Payload delivered to APM server")
    }
    
    private func handleHttpFailure(_ urlResponse: HTTPURLResponse, _ error: Error?) {
        let errorDescription: String
        if let error = error {
            errorDescription = "\(error)"
        } else {
            errorDescription = "n/a"
        }
        logger.error("Error sending data to APM server, statusCode=\(urlResponse.statusCode) error=\(errorDescription)")
        logger.debug("Sending payload to APM server failed: urlResponse=\(urlResponse)")
    }
}
