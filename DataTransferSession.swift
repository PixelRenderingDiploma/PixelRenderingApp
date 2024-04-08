//
//  DataTransferSession.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Foundation

enum DataTransferSessionOutput {
    case initializing
    case startProcessing
    
    case requestProgress(Float)
    
    case requestCancelled
    case requestError(error: Error)
    case requestCompleted
}

protocol DataTransferSessionProtocol {
    typealias Output = DataTransferSessionOutput
    typealias Updates = CombineAsyncPublsiher<Published<Output>.Publisher>
    
    func startUploading()
    func process() async throws -> AsyncThrowingStream<Output, Swift.Error>
    func handleOutput(_ output: Output) async throws
    
    func cancel()
}

class DataTransferSession: NSObject, DataTransferSessionProtocol {
    enum Error: LocalizedError {
        case cancelled
        
        var errorDescription: String? {
            switch self {
            case .cancelled:
                "Cancelled"
            }
        }
    }
    
    let id: UUID
    let webApi: WebApi
    
    var isCancelled = false
    
    @Published var output: Output = .initializing
    var outputUpdates: CombineAsyncPublsiher<Published<Output>.Publisher> {
        $output.sequence
    }
    
    init(id: UUID, webApi: WebApi) {
        self.id = id
        self.webApi = webApi
    }
    
    func startUploading() {
        guard case .initializing = output else {
            return
        }
        
        Task { [weak self] in
            do {
                guard let outputs = try await self?.process() else {
                    return
                }
                
                for try await output in outputs {
                    guard let self else {
                        return
                    }
                    
                    try await self.handleOutput(output)
                    
                    await MainActor.run {
                        self.output = output
                    }
                }
                
                print(">>>>>>>>>> DATA TRANSFER TASK EXIT >>>>>>>>>>>>>>>>>")
            } catch {
                print("Uploading task error. \(error.localizedDescription)")
            }
        }
    }
    
    func process() async throws -> AsyncThrowingStream<Output, Swift.Error> {
        AsyncThrowingStream<Output, Swift.Error> { continuation in
            continuation.finish()
        }
    }
    
    func handleOutput(_ outputs: Output) async throws {}
    
    func checkCancellation() throws {
        if isCancelled { throw Error.cancelled }
    }
    
    func cancel() {
        isCancelled = true
    }
}
