//
//  SyncService.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-02.
//

import Foundation

enum SyncStatus {
    case local
    case cloud
    case synced
}

class SyncService {
    enum SyncError: Error {
        case unauthorizedRequest
        case unprocessableEntity
    }
    
    private let queue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    private var operationIDs = [UUID]()
    private var webApi: WebApi?
    
    init() {
        print("sync init")
    }
    
    func authorize(_ auth: MSAuthState) {
        self.webApi = WebApi(auth)
    }
    
    func unauthorize() {
        self.webApi = nil
    }
    
    func createProject(with id: UUID, modelPath: URL) async throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        try await webApi.putUserBlob(blobPath: "models/\(id.uuidString.lowercased()).glb", data: Data(contentsOf: modelPath))
    }
    
    func syncStatus(for storageItem: StorageItem) async throws -> SyncStatus {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let url = storageItem.url else {
            throw SyncError.unprocessableEntity
        }
        
        let local = FileManager.default.fileExists(atPath: url.path())
        
        
        let blobPaths = try await webApi.getUserFilesListInResources(blobPrefix: "models/")
        let blobIDs = Set(blobPaths.map { $0.deletingPathExtension().lastPathComponent })
        
        let cloud = blobIDs.contains(storageItem.id.uuidString.lowercased())
        
        return switch (local, cloud) {
        case (true, true):
            .synced
        case (false, true):
            .cloud
        case (true, false):
            .local
        case (false, false):
            throw SyncError.unprocessableEntity
        }
    }
    
    func fetchCloudProjects() async throws -> [UUID] {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        let blobPaths = try await webApi.getUserFilesListInResources(blobPrefix: "models/")
        return blobPaths.compactMap { UUID(uuidString: $0.deletingPathExtension().lastPathComponent) }
    }
}
