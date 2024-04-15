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
    
    private var outputPublishers = [UUID: Published<DataTransferSession.Output>.Publisher]()
    
    func add(session: DataTransferSession) {
        let op = DataTransferOperation(session: session)
        outputPublishers[session.id] = session.$output
        operationQueue.addOperation(op)
        
        let outputs = updates(for: session.id)!
        
        Task { [weak self] in
            for await output in outputs {
                guard let self else {
                    return
                }
                
                switch output {
                case .requestCompleted, .requestCancelled, .requestError:
                    self.outputPublishers.removeValue(forKey: session.id)
                default:
                    break
                }
            }
        }
    }
    
    func updates(for id: UUID) -> UntilProcessingCompleteFilter<DataTransferSession.Updates>? {
        guard let outputPublisher = outputPublishers[id] else {
            return nil
        }
        
        return UntilProcessingCompleteFilter(input: outputPublisher.sequence) {
            switch $0 {
            case .requestCompleted, .requestError, .requestCancelled:
                true
            default:
                false
            }
        }
    }
}
