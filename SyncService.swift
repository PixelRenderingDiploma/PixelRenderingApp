//
//  SyncService.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-02.
//

import Foundation

class SyncService {
    private let queue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    private var operationIDs = [UUID]()
    private var webApi: WebApi?
    
    func authorize(_ auth: MSAuthState) {
        self.webApi = WebApi(auth)
    }
    
    func unauthorize() {
        self.webApi = nil
    }
    
    func createProject(with id: UUID, modelPath: URL) async throws {
        guard let webApi else {
            return
        }
        
        try await webApi.putUserBlob(blobPath: "models/\(id.uuidString.lowercased()).glb", data: Data(contentsOf: modelPath))
    }
    
    func download(project: UUID) {
        
    }
    
    func download(video: UUID) {
        
    }
    
    func download(image: UUID) {
        
    }
}
