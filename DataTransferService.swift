//
//  DataTransferService.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Foundation

class DataTransferService {
    private let operationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var operationUpdates = [UUID: CombineAsyncPublsiher<Published<DataTransferSession.Output>.Publisher>]()
    
    func add(session: DataTransferSession) {
        let op = DataTransferOperation(session: session)
        operationUpdates[session.id] = session.outputUpdates
        operationQueue.addOperation(op)
        
        let outputs = UntilProcessingCompleteFilter(input: session.outputUpdates)
        
        Task { [weak self] in
            for await output in outputs {
                guard let self else {
                    return
                }
                
                switch output {
                case .requestCompleted, .requestCancelled, .requestError:
                    self.operationUpdates.removeValue(forKey: session.id)
                default:
                    break
                }
            }
        }
    }
    
    func updates(for id: UUID) -> UntilProcessingCompleteFilter<DataTransferSession.Updates>? {
        guard let operationUpdates = operationUpdates[id] else {
            return nil
        }
        
        return UntilProcessingCompleteFilter(input: operationUpdates)
    }
}
