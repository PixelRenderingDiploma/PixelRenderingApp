//
//  ProjectSyncService.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-02-05.
//

import Foundation

class ProjectSyncService {
    func sync(_ storageItem: StorageItem, webApi: WebApi) {
        let id = storageItem.id
        
        Task {
            do {
                _ = try await syncImages(for: id, webApi: webApi)
                _ = try await syncVideos(for: id, webApi: webApi)
            } catch {
                print(error)
            }
        }
    }
    
    private func syncImages(for project: UUID, webApi: WebApi) async throws -> [URL] {
        guard let projectManager = ProjectFolderManager(with: project) else {
            return []
        }
        
        let localImages = projectManager.images
        let blobPaths = try await webApi.getUserFilesListInResources(blobPrefix: "renders/images")
        
        let localNames = Set(localImages.map { $0.lastPathComponent })
        let blobNames = Set(blobPaths.map { $0.lastPathComponent })
        
        let toDownload = blobNames.subtracting(localNames)
        let blobsFolder = URL(fileURLWithPath: "renders/images")
        
        var savedImagesURL = [URL]()
        for blobName in toDownload {
            let blob = blobsFolder.appending(path: blobName)
            let data = try await webApi.getUserBlob(blobPath: blob.path())
            let imageURL = projectManager.imagesFolder.appending(path: blobName)
            try data.write(to: imageURL)
            savedImagesURL.append(imageURL)
        }
        
        return savedImagesURL
    }
    
    private func syncVideos(for project: UUID, webApi: WebApi) async throws -> [URL] {
        guard let projectManager = ProjectFolderManager(with: project) else {
            return []
        }
        
        let localVideos = projectManager.videos
        let blobPaths = try await webApi.getUserFilesListInResources(blobPrefix: "renders/videos")
        
        let localNames = Set(localVideos.map { $0.lastPathComponent })
        let blobNames = Set(blobPaths.map { $0.lastPathComponent })
        
        let toDownload = blobNames.subtracting(localNames)
        let blobsFolder = URL(fileURLWithPath: "renders/videos")
        
        var savedImagesURL = [URL]()
        for blobName in toDownload {
            let blob = blobsFolder.appending(path: blobName)
            let data = try await webApi.getUserBlob(blobPath: blob.path())
            let videoURL = projectManager.imagesFolder.appending(path: blobName)
            try data.write(to: videoURL)
            savedImagesURL.append(videoURL)
        }
        
        return savedImagesURL
    }
}

struct BlobItem {
    let url: URL
    let date: Date
}
