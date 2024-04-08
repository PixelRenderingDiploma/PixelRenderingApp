//
//  DownloadingSession.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Foundation

class DownloadingSession: DataTransferSession {
    private lazy var urlSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: id.uuidString + "\(Date.now.timeIntervalSince1970)")
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 240
        configuration.timeoutIntervalForResource = 240
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    let blobPath: String
    let saveURL: URL
    
    init(id: UUID, webApi: WebApi, blobPath: String, saveURL: URL) {
        self.blobPath = blobPath
        self.saveURL = saveURL
        
        super.init(id: id, webApi: webApi)
    }
    
    override func process() async throws -> AsyncThrowingStream<Output, Swift.Error> {
        let output = AsyncThrowingStream<Output, Swift.Error> { continuation in
            Task {
                do {
                    continuation.yield(.startProcessing)
                    
                    try self.checkCancellation()
                    
                    let data = try await webApi.getUserBlob(
                        blobPath: blobPath,
                        session: urlSession,
                        delegate: self,
                        progressHandler: { continuation.yield(.requestProgress($0)) })
                    
                    try data.write(to: saveURL)
                    
                    continuation.yield(.requestCompleted)
                    continuation.finish()
                } catch {
                    if isCancelled {
                        continuation.yield(.requestCancelled)
                        continuation.finish()
                    } else {
                        continuation.yield(.requestError(error: error))
                        continuation.finish(throwing: error)
                    }
                }
                
                urlSession.invalidateAndCancel()
            }
        }
        
        return output
    }
    
    override func cancel() {
        super.cancel()
        urlSession.invalidateAndCancel()
    }
}

extension DownloadingSession: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
}
