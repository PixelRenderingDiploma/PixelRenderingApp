//
//  DataTransferOperation.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Foundation

class DataTransferOperation: AsyncOperation {
    let session: DataTransferSession
    
    init(session: DataTransferSession) {
        self.session = session
    }
    
    override func main() {
        session.startUploading()
        
        let outputs = UntilProcessingCompleteFilter(input: session.outputUpdates)
        
        Task { [weak self] in
            for await _ in outputs {}
            
            self?.finish()
        }
    }
    
    override func cancel() {
        super.cancel()
        self.session.cancel()
    }
}
