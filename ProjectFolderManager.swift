//
//  ProjectFolderManager.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-30.
//

import Foundation
import os

class ProjectFolderManager {
    static let logger = Logger(subsystem: AppDelegate.subsystem,
                               category: "CaptureFolderManager")
    private let logger = ProjectFolderManager.logger
    
    var rootProjectFolder: URL
    
    var imagesFolder: URL
    var videosFolder: URL
    
    init?() {
        guard let newFolder = ProjectFolderManager.createNewProjectDirectory() else {
            logger.error("Unable to create a new scan directory.")
            return nil
        }
        
        rootProjectFolder = newFolder
        
        imagesFolder = newFolder.appendingPathComponent("Images/")
        guard ProjectFolderManager.createDirectoryRecursively(imagesFolder) else {
            return nil
        }
        
        videosFolder = newFolder.appendingPathComponent("Videos/")
        guard ProjectFolderManager.createDirectoryRecursively(videosFolder) else {
            return nil
        }
    }
    
    init?(with id: UUID) {
        guard let existingFolder = ProjectFolderManager.getProjectDirectory(with: id) else {
            return nil
        }
        
        rootProjectFolder = existingFolder
        
        imagesFolder = existingFolder.appendingPathComponent("Images/")
        _ = ProjectFolderManager.createDirectoryRecursively(imagesFolder)
        videosFolder = existingFolder.appendingPathComponent("Videos/")
        _ = ProjectFolderManager.createDirectoryRecursively(videosFolder)
    }
    
    var id: UUID {
        UUID(uuidString: rootProjectFolder.lastPathComponent)!
    }
    
    // Default model path. Used when project fetched from cloud
    var defaultModelURL: URL {
        return rootProjectFolder.appending(path: id.uuidString.lowercased()).appendingPathExtension(for: .glb)
    }
    
    var images: [URL] {
        (try? FileManager.default.contentsOfDirectory(at: imagesFolder, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])) ?? []
    }
    
    func image(with id: UUID) -> URL? {
        let idStr = id.uuidString.lowercased()
        let url = imagesFolder.appending(path: idStr).appendingPathExtension(for: .mpeg4Movie)
        
        guard FileManager.default.fileExists(atPath: url.path()) else {
            return nil
        }
        
        return url
    }
    
    var videos: [URL] {
        (try? FileManager.default.contentsOfDirectory(at: videosFolder, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])) ?? []
    }
    
    func video(with id: UUID) -> URL? {
        let idStr = id.uuidString.lowercased()
        let url = videosFolder.appending(path: idStr).appendingPathExtension(for: .mpeg4Movie)
        
        guard FileManager.default.fileExists(atPath: url.path()) else {
            return nil
        }
        
        return url
    }
    
    /// Returns the app documents folder for all our captures.
    static func rootProjectsFolder() -> URL? {
        guard let documentsFolder =
                try? FileManager.default.url(for: .documentDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: false) else {
            return nil
        }
        
        return documentsFolder.standardized.appendingPathComponent("Projects/", isDirectory: true)
    }
    
    /// Creates a new Project directory based on the current timestamp in the top level Documents
    /// folder.
    /// - Returns: The new Scans folder's file URL, or `nil` on error.
    static func createNewProjectDirectory(_ id: UUID = UUID()) -> URL? {
        guard let projectsFolder = rootProjectsFolder() else {
            logger.error("Can't get user document dir!")
            return nil
        }
        
        let newCaptureDir = projectsFolder
            .appending(path: id.uuidString.lowercased(), directoryHint: .isDirectory)
        
        logger.log("Creating project path: \"\(String(describing: newCaptureDir))\"")
        let capturePath = newCaptureDir.path()
        do {
            try FileManager.default.createDirectory(atPath: capturePath,
                                                    withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create projectpath=\"\(capturePath)\" error=\(String(describing: error))")
            return nil
        }
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: capturePath, isDirectory: &isDir)
        guard exists && isDir.boolValue else {
            return nil
        }
        
        return newCaptureDir
    }
    
    static func getProjectDirectory(with id: UUID) -> URL? {
        guard let projectsFolder = rootProjectsFolder() else {
            logger.error("Can't get user document dir!")
            return nil
        }
        
        return projectsFolder.appending(path: id.uuidString.lowercased(), directoryHint: .isDirectory)
    }
    
    static func getProjects() -> [UUID] {
        guard let projectsFolder = rootProjectsFolder() else {
            logger.error("Can't get user document dir!")
            return []
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: projectsFolder.path())
            
            let directories = contents.filter { item in
                var isDirectory: ObjCBool = false
                let url = projectsFolder.appending(path: item)
                if FileManager.default.fileExists(atPath: url.path(), isDirectory: &isDirectory) {
                    return isDirectory.boolValue
                }
                return false
            }
            
            return directories.compactMap { UUID(uuidString: $0) }
        } catch {
            logger.error("\(error.localizedDescription)")
            return []
        }
    }
    
    static func delete(with id: UUID) {
        guard let projectsFolder = rootProjectsFolder() else {
            logger.error("Can't get user document dir!")
            return
        }
        
        try? FileManager.default.removeItem(at: projectsFolder.appending(path: id.uuidString.lowercased()))
        
        NotificationCenter.default.post(name: .didDeleteProjectFolder, object: nil, userInfo: ["id": id])
    }
    
    // - MARK: Private interface below.

    /// Creates all path components for the output directory.
    /// - Parameter outputDir: A URL for the new output directory.
    /// - Returns: A Boolean value that indicates whether the method succeeds,
    /// otherwise `false` if it encounters an error, such as if the file already
    /// exists or the method couldn't create the file.
    private static func createDirectoryRecursively(_ outputDir: URL) -> Bool {
        guard outputDir.isFileURL else {
            return false
        }
        let expandedPath = outputDir.path
        var isDirectory: ObjCBool = false
        let fileManager = FileManager()
        guard !fileManager.fileExists(atPath: outputDir.path, isDirectory: &isDirectory) else {
            logger.warning("File already exists at \(expandedPath, privacy: .private)")
            return false
        }

        logger.log("Creating dir recursively: \"\(expandedPath, privacy: .private)\"")

        let result: ()? = try? fileManager.createDirectory(atPath: expandedPath,
                                                           withIntermediateDirectories: true)

        guard result != nil else {
            return false
        }

        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: expandedPath, isDirectory: &isDir) && isDir.boolValue else {
            logger.error("Dir \"\(expandedPath, privacy: .private)\" doesn't exist after creation!")
            return false
        }

        logger.log("... success creating dir.")
        return true
    }
}

extension ProjectFolderManager {
    var paragraphs: [URL] {
        [videosFolder, imagesFolder]
    }
}

extension Notification.Name {
     static let didDeleteProjectFolder = Notification.Name("didDeleteProject")
}
