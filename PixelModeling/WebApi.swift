//
//  WebApi.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-20.
//

import Foundation

class WebApi {
    enum Error: Swift.Error {
        case unauthorizedRequest
        case invalidURL(stringURL: String? = nil)
        case failedToConvert
    }
    
    private let apiUrl = "https://pixelrenderer-azurefunctions.azurewebsites.net/api"
    
    private let encoder = JSONEncoder()
    
    private(set) var auth = MSAuthState()
    
    init (_ auth: MSAuthState) {
        self.auth = auth
    }
    
    func getUserBlobSasUrl(blobPath: String, session: URLSession = .shared) async throws -> URL {
        guard let idToken = auth.idToken else {
            throw Error.unauthorizedRequest
        }
        
        let apiEndpoint = "\(apiUrl)/GetUserBlobSasUrl?blobPath=\(blobPath)"
        guard let url = URL(string: apiEndpoint) else {
            throw Error.invalidURL(stringURL: apiEndpoint)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await session.data(for: request)
        
        guard let sasUrlString = String(data: data, encoding: .utf8),
              let sasUrl = URL(string: sasUrlString) else {
            throw Error.invalidURL()
        }
        
        return sasUrl
    }
    
    func getUserBlob(blobPath: String, session: URLSession = .shared) async throws -> Data {
        let sasUrl = try await getUserBlobSasUrl(blobPath: blobPath)
        
        var request = URLRequest(url: sasUrl)
        request.httpMethod = "GET"
        
        let (data, _) = try await session.data(for: request)
        
        return data
    }
    
    func getUserBlob(blobPath: String, session: URLSession, delegate: URLSessionDownloadDelegate, progressHandler: @escaping (Float) -> Void) async throws -> Data {
        let sasUrl = try await getUserBlobSasUrl(blobPath: blobPath)
        
        var request = URLRequest(url: sasUrl)
        request.httpMethod = "GET"
        
        let (bytesStream, urlResponse) = try await session.bytes(for: request)
        
        let expectedLength = Int(urlResponse.expectedContentLength)
        var data = Data(capacity: expectedLength)
        
        var fastRunningProgress: Float = 0
        for try await bytes in bytesStream {
            data.append(bytes)
            let progress = Float(data.count) / Float(expectedLength)
            if Int(fastRunningProgress * 100) != Int(progress * 100) {
                fastRunningProgress = progress
                progressHandler(progress)
            }
        }
        
        return data
    }
    
    func putUserBlob(blobPath: String, data: Data, session: URLSession = .shared) async throws {
        let sasUrl = try await getUserBlobSasUrl(blobPath: blobPath)
        
        var request = URLRequest(url: sasUrl)
        request.httpMethod = "PUT"
        request.setValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
        
        request.httpBody = data
        
        _ = try await session.data(for: request)
    }
    
    func deleteUserBlob(blobPath: String, session: URLSession = .shared) async throws -> Bool {
        guard let idToken = auth.idToken else {
            throw Error.unauthorizedRequest
        }
        
        let apiEndpoint = "\(apiUrl)/DeleteUserResourceFile?blobPath=\(blobPath)"
        guard let url = URL(string: apiEndpoint) else {
            throw Error.invalidURL(stringURL: apiEndpoint)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        
        return (response as? HTTPURLResponse)?.statusCode == 200
    }
    
    func getUserResources(blobPrefix: String, session: URLSession = .shared) async throws -> [String: Any] {
        guard let idToken = auth.idToken else {
            throw Error.unauthorizedRequest
        }
        
        let apiEndpoint = "\(apiUrl)/GetUserResourceFiles?blobPrefix=\(blobPrefix)"
        guard let url = URL(string: apiEndpoint) else {
            throw Error.invalidURL(stringURL: apiEndpoint)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await session.data(for: request)
        
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
    
    func getUserFilesListInResources(blobPrefix: String, session: URLSession = .shared) async throws -> [URL] {
        let json = try await getUserResources(blobPrefix: blobPrefix)
        var result = [URL]()
        (json["directories"] as? [[String: Any]])?.forEach { directory in
            guard let files = directory["Files"] as? [[String: Any]] else {
                return
            }
            
            files.forEach { file in
                guard let name = file["Name"] as? String else {
                    return
                }
                
                result.append(URL(fileURLWithPath: name))
            }
        }
        
        return result
    }
    
    @discardableResult
    func notifyRendererQueue(json: Any, session: URLSession = .shared) async throws -> Bool {
        let apiEndpoint = "\(apiUrl)/RendererQueue?queue=debug"
        guard let url = URL(string: apiEndpoint) else {
            throw Error.invalidURL(stringURL: apiEndpoint)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = jsonData
        
        let (_, response) = try await session.data(for: request)
        
        return ((response as? HTTPURLResponse)?.statusCode ?? 400) == 201
    }
    
    func getRendererPostJson(id: UUID, id_model: UUID, settings: RenderingSettings) throws -> [String: Any] {
        guard let idToken = auth.idToken else {
            throw Error.unauthorizedRequest
        }
        
        guard let settingsData = try? JSONEncoder().encode(settings),
              let settingsJson = String(data: settingsData, encoding: .utf8) else {
            throw Error.failedToConvert
        }
        
        let idString = id.uuidString.lowercased()
        let idModelString = id_model.uuidString.lowercased()
        
        let json: [String: Any] = [
            "id": idString,
            "id_token": idToken,
            "id_model": idModelString,
            "status": "queue",
            "settings": settingsJson
        ]
        
        return json
    }
    
    func submitRendering(id: UUID, id_model: UUID, settings: RenderingSettings, session: URLSession = .shared) async throws {
        let json = try getRendererPostJson(id: id, id_model: id_model, settings: settings)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        
        try await putUserBlob(blobPath: "configs/requests/\(id.uuidString.lowercased()).json", data: jsonData, session: session)
        try await notifyRendererQueue(json: json, session: session)
    }
}
