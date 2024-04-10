//
//  UploadingSession.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-09.
//

import Foundation

import Foundation

class UploadingSession: DataTransferSession {
    private lazy var urlSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: id.uuidString + "\(Date.now.timeIntervalSince1970)")
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 240
        configuration.timeoutIntervalForResource = 240
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    let blobPath: String
    let data: Data
    
    private var continuation: AsyncThrowingStream<Output, Swift.Error>.Continuation?
    private var totalBytesSent: Int64
    private var totalBytesExpectedToSend: Int64
    
    init(id: UUID, webApi: WebApi, blobPath: String, data: Data) {
        self.blobPath = blobPath
        self.data = data
        
        self.totalBytesSent = 0
        self.totalBytesExpectedToSend = Int64(data.count)
        
        super.init(id: id, webApi: webApi)
    }
    
    override func process() async throws -> AsyncThrowingStream<Output, Swift.Error> {
        let output = AsyncThrowingStream<Output, Swift.Error> { continuation in
            self.continuation = continuation
            Task {
                do {
                    continuation.yield(.startProcessing)
                    
                    try self.checkCancellation()
                    
                    try await webApi.putUserBlob(
                        blobPath: blobPath,
                        data: data,
                        delegate: self)
                    
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

extension UploadingSession: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.totalBytesSent += bytesSent
        
        let progress = Float(self.totalBytesSent)
        let processProgress = progress / Float(self.totalBytesExpectedToSend)
        
        continuation?.yield(.requestProgress(processProgress))
    }
}
