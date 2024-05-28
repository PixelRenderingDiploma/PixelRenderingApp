//
//  SyncService.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-02.
//

import Foundation

enum SyncStatus {
    case local
    case cloudContent
    case cloud
    case synced
    case syncing
    
    var systemSymbolName: String {
        switch self {
        case .local:
            "icloud.and.arrow.up"
        case .cloud:
            "icloud.and.arrow.down"
        case .cloudContent, .syncing:
            "arrow.triangle.2.circlepath.icloud"
        case .synced:
            "checkmark.icloud"
        }
    }
}

class SyncService {
    enum SyncError: Error {
        case unauthorizedRequest
        case unprocessableEntity
    }
    
    let dataTransfer = DataTransferService()
    let requestAggregator = DynamicUpdateAggregator<RemoteContentStatusLoader>(.empty)
    private(set) var webApi: WebApi?
    
    func authorize(_ auth: MSAuthState) {
        self.webApi = WebApi(auth)
    }
    
    func unauthorize() {
        self.webApi = nil
    }
    
    func createProject(with item: StorageItem) throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let url = item.url,
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        let session = UploadingSession(
            id: item.id,
            webApi: webApi,
            blobPath: "models/\(item.id.uuidString.lowercased()).glb",
            data: data)
        
        dataTransfer.add(session: session)
    }
    
    func createProject(with id: UUID) throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let folderManager = ProjectFolderManager(with: id),
              let data = try? Data(contentsOf: folderManager.defaultModelURL) else {
            return
        }
        
        let session = UploadingSession(
            id: id,
            webApi: webApi,
            blobPath: "models/\(id.uuidString.lowercased()).glb",
            data: data)
        
        dataTransfer.add(session: session)
    }
    
    func downloadProject(with id: UUID) throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let folderManager = ProjectFolderManager(with: id) else {
            return
        }
        
        let session = DownloadingSession(
            id: id,
            webApi: webApi,
            blobPath: "models/\(id.uuidString.lowercased()).glb",
            saveURL: folderManager.defaultModelURL)
        
        dataTransfer.add(session: session)
    }
    
    // Download missing/new images/videos
    func syncProject(with id: UUID) async throws -> [String: Set<String>]{
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let project = ProjectFolderManager(with: id) else {
            throw SyncError.unprocessableEntity
        }
        
        let content = try await missingContent(for: id)
        
        let projectFolder = project.rootProjectFolder
        for (paragraph, names) in content {
            for name in names {
                guard let idContentStr = name.split(separator: ".").first,
                      let idContent = UUID(uuidString: String(idContentStr)) else {
                    continue
                }
                
                let session = DownloadingSession(
                    id: idContent,
                    webApi: webApi,
                    blobPath: "renders/\(paragraph)/\(id.uuidString.lowercased())/\(name)",
                    saveURL: projectFolder.appending(path: paragraph).appending(path: name))
                
                dataTransfer.add(session: session)
            }
        }
        
        return content
    }
    
    /// Return missing content for project
    /// - Parameters:
    ///   - id: project id
    ///   - includePlaceholders: if ture, when counting missing files, if placeholders exists in file system, will count it as missing (remote) file
    /// - Returns: dictionary of "paragraph": [content]
    func missingContent(for id: UUID, includePlaceholders: Bool = true) async throws -> [String: Set<String>] {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        guard let project = ProjectFolderManager(with: id) else {
            throw SyncError.unprocessableEntity
        }
        
        let idStr = id.uuidString.lowercased()
        
        async let imagePathsRequest = webApi.getUserFilesListInResources(blobPrefix: "renders/images/\(idStr)/")
        async let videoPathsRequest = webApi.getUserFilesListInResources(blobPrefix: "renders/videos/\(idStr)/")
        let (imagePaths, videoPaths) = try await (imagePathsRequest, videoPathsRequest)
        
        let localImagePaths = project.images.filter { includePlaceholders ? !$0.isPlaceholder : true }
        let localVideoPaths = project.videos.filter { includePlaceholders ? !$0.isPlaceholder : true }
        
        let missingImages = Set(imagePaths.map { $0.lastPathComponent }).subtracting(Set(localImagePaths.map { $0.lastPathComponent }))
        let missingVideos = Set(videoPaths.map { $0.lastPathComponent }).subtracting(Set(localVideoPaths.map { $0.lastPathComponent }))
        
        return [
            "images": missingImages,
            "videos": missingVideos
        ]
    }
    
    //                                        Model  Subfolder   Request
    func processingContent() async throws -> [UUID: [String: Set<String>]] {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        async let configPathsRequest = webApi.getUserFilesListInResources(blobPrefix: "configs/requests/")
        async let imagePathsRequest = webApi.getUserFilesListInResources(blobPrefix: "renders/images/")
        async let videoPathsRequest = webApi.getUserFilesListInResources(blobPrefix: "renders/videos/")
        let (configPaths, imagePaths, videoPaths) = try await (configPathsRequest, imagePathsRequest, videoPathsRequest)
        
        let configIDs = Set(configPaths.compactMap { $0.deletingPathExtension().lastPathComponent })
        let imageIDs = Set(imagePaths.compactMap { $0.deletingPathExtension().lastPathComponent })
        let videoIDs = Set(videoPaths.compactMap { $0.deletingPathExtension().lastPathComponent })
        
        let processingIDs = configIDs.subtracting(imageIDs).subtracting(videoIDs)
        
        var result = [UUID: [String: Set<String>]]()
        
        try await withThrowingTaskGroup(of: RenderingRequest.self) { group in
            for id in processingIDs {
                group.addTask {
                    let data = try await webApi.getUserBlob(blobPath: "configs/requests/\(id).json")
                    let request = try JSONDecoder().decode(RenderingRequest.self, from: data)
                    
                    return request
                }
            }
            
            // TODO: add format based on request
            for try await request in group {
                guard let id = UUID(uuidString: request.id_model) else {
                    continue
                }
                
                if result[id] == nil { result[id] = ["images": [], "videos": []] }
                
                switch request.settings.type {
                case .image:
                    result[id]?["images"]?.insert(request.id + ".png")
                case .video:
                    result[id]?["videos"]?.insert(request.id + ".mp4")
                }
            }
        }
        
        return result
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
        
        let idStr = storageItem.id.uuidString.lowercased()
        
        let modelSize = try? FileManager.default.attributesOfItem(atPath: url.path())[.size] as? NSNumber
        let local = (modelSize?.intValue ?? 0) > 0 // Check if file is not a placeholder
        
        let blobPaths = try await webApi.getUserFilesListInResources(blobPrefix: "models/")
        let blobIDs = Set(blobPaths.map { $0.deletingPathExtension().lastPathComponent })
        let cloud = blobIDs.contains(idStr)
        
        let content = try await missingContent(for: storageItem.id)
        let syncedContent = content.values.reduce(0) { $0 + $1.count } == 0
        
        return switch (local, cloud, syncedContent) {
        case (true, true, true):
            .synced
        case (true, true, false):
            .cloudContent
        case (true, false, _):
            .local
        case (false, true, _):
            .cloud
        default:
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
    
    func startObservingRequest(with id: UUID) throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        let loader = RemoteContentStatusLoader(id: id, webApi: webApi)
        loader.start()
        requestAggregator.add(id, loader)
    }
    
    func submit(model: UUID, settings: RenderingSettings) async throws {
        guard let webApi else {
            throw SyncError.unauthorizedRequest
        }
        
        let id = UUID()
        try await webApi.submitRequest(id: id, id_model: model, settings: settings)
        
        try startObservingRequest(with: id)
    }
}
