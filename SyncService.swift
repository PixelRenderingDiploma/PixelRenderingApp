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
    
    var systemSymbolName: String {
        switch self {
        case .local:
            "icloud.and.arrow.up"
        case .cloud:
            "icloud.and.arrow.down"
        case .synced:
            "checkmark.icloud"
//        case .needSync:
        }
    }
}

class SyncService {
    enum SyncError: Error {
        case unauthorizedRequest
        case unprocessableEntity
    }
    
    let dataTransfer = DataTransferService()
    private(set) var webApi: WebApi?
    
    func authorize(_ auth: MSAuthState) {
        self.webApi = WebApi(auth)
    }
    
    func unauthorize() {
        self.webApi = nil
    }
    
    func createProject(with id: UUID) throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let folderManager = ProjectFolderManager(with: id) else {
            return
        }
        
//        let session = UploadingSession(blobPath: "models/\(id.uuidString.lowercased()).glb",
//                                       data: Data(contentsOf: folderManager.defaultModelURL))
//        
//        dataTransfer.add(session: session)
    }
    
    func downloadProject(with id: UUID) throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let folderManager = ProjectFolderManager(with: id) else {
            return
        }
        
        let session = DownloadingSession(id: id,
                                         webApi: webApi,
                                         blobPath: "models/\(id.uuidString.lowercased()).glb",
                                         saveURL: folderManager.defaultModelURL)
        
        dataTransfer.add(session: session)
    }
    
    // Download missing/new images/videos
    func syncProject(with id: UUID) {
        
    }
    
    func delete(project id: UUID) async throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        async let imagePathsRequest = webApi.getUserFilesListInResources(blobPrefix: "renders/images/\(id.uuidString.lowercased())/")
        async let videoPathsRequest = webApi.getUserFilesListInResources(blobPrefix: "renders/videos/\(id.uuidString.lowercased())/")
        
        let (imagePaths, videoPaths) = try await (imagePathsRequest, videoPathsRequest)
        
        for path in imagePaths + videoPaths {
            _ = try await webApi.deleteUserBlob(blobPath: path.path())
        }
        
        try await delete(model: id)
    }
    
    func delete(model id: UUID) async throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        _ = try await webApi.deleteUserBlob(blobPath: "models/\(id.uuidString.lowercased()).glb")
    }
    
    func syncStatus(for storageItem: StorageItem) async throws -> SyncStatus {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let url = storageItem.url else {
            throw SyncError.unprocessableEntity
        }
        
        let modelSize = try? FileManager.default.attributesOfItem(atPath: url.path())[.size] as? NSNumber
        let local = (modelSize?.intValue ?? 0) > 1 // Check if file is not a placeholder
        
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
        
        let paths = try await webApi.getUserFilesListInResources(blobPrefix: "models/")
        return paths.compactMap { UUID(uuidString: $0.deletingPathExtension().lastPathComponent) }
    }
}
