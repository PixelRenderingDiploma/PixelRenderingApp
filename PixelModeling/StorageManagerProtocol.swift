//
//  StorageManagerProtocol.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-27.
//

import Foundation
import SwiftData
import Observation

@Model
class StorageItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var bookmark: Data
    
    init(id: UUID = UUID(), name: String, bookmark: Data) {
        self.id = id
        self.name = name
        self.bookmark = bookmark
    }
    
    var url: URL? {
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale) else {
            return nil
        }
        
        if isStale {
            do {
                self.bookmark = try url.bookmarkData()
            } catch {
                print(error)
            }
        }
        
        return url
    }
}

protocol StorageManagerProtocol {
    var persistantContainer: ModelContainer { get }
    
    func getAll() -> [StorageItem]
    func get(with id: UUID) -> StorageItem?
    func insert(_ item: StorageItem)
    
    func delete(_ item: StorageItem)
    func delete(with id: UUID)
}

extension StorageManagerProtocol {
    @MainActor func getAll() -> [StorageItem] {
        do {
            let data = try persistantContainer.mainContext.fetch(FetchDescriptor<StorageItem>())
            debugPrint("getAllObjects: \(data.map { ($0.id, $0.url) })")
            return data
        } catch {
            debugPrint("getAllObjects: data is nil")
            return []
        }
    }
    
    @MainActor func get(with id: UUID) -> StorageItem? {
        do {
            var predicate = #Predicate<StorageItem> { object in
                object.id == id
            }
            var descriptor = FetchDescriptor(predicate: predicate)
            let data = try persistantContainer.mainContext.fetch(descriptor).first
            debugPrint("getObject with id=\(id) : \(String(describing: data))")
            return data
        } catch {
            debugPrint("getAllObjects : data is nil")
            return nil
        }
    }
    
    @MainActor
    func insert(_ item: StorageItem) {
        persistantContainer.mainContext.insert(item)
        debugPrint("Inserting item: \(item)")
        
        try? persistantContainer.mainContext.save()
    }
    
    @MainActor
    func delete(_ item: StorageItem) {
        do {
            persistantContainer.mainContext.delete(item)
            
            debugPrint("Delete item: \(item)")
            try persistantContainer.mainContext.save()
        } catch {
            debugPrint("deleting item with id: \(item.id), name: \(item.name) failed")
        }
    }
    
    @MainActor
    func delete(with id: UUID) {
        do {
            try persistantContainer.mainContext.delete(model: StorageItem.self, where: #Predicate { item in
                item.id == id
            })
            
            try persistantContainer.mainContext.save()
        } catch {
            debugPrint("deleting item with id: \(id) failed")
        }
    }
}

class StorageItemBookmark {
    private var bookmark: Data
    
    init?(url: URL) {
        guard let data = try? url.bookmarkData() else {
            return nil
        }
        
        self.bookmark = data
    }
    
    var data: Data? {
        var isStale = false
        let url = try? URL(resolvingBookmarkData: bookmark,
                           options: .withSecurityScope,
                           relativeTo: nil,
                           bookmarkDataIsStale: &isStale)
        
        guard let url else {
            return nil
        }
        
        return try? Data(contentsOf: url)
    }
}

class StorageManagerMacOS: StorageManagerProtocol {
    let persistantContainer: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: StorageItem.self,
                configurations: ModelConfiguration()
            )
            return container
        } catch {
            fatalError("Failed to create a container")
        }
    }()
}
