//
//  ContentPreviewLoader.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-09.
//

import AppKit
import UniformTypeIdentifiers
import AVFoundation
import CoreImage
import GLTFSceneKit

class ContentPreviewLoader {
    enum Error: Swift.Error {
        case unsupportedContentType
        case couldNotCreateImage
    }
    
    typealias Handler = (Result<NSImage, Swift.Error>) -> Void
    
    private let cache = Cache<URL, NSImage>()
    
    func loadPreview(for url: URL,
                     handler: @escaping Handler) {
        if let cached = cache[url] {
            return handler(.success(cached))
        }
        
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return handler(.failure(Error.unsupportedContentType))
        }
        
        Task {
            do {
                let thumbnail: NSImage
                
                if type.conforms(to: .threeDContent) {
                    let data = try Data(contentsOf: url)
                    let sceneSource = GLTFSceneSource(data: data)
                    let scene = try sceneSource.scene(options: nil)
                    thumbnail = try SCNPreviewGenerator.thumbnail(for: scene, size: CGSize(width: 512, height: 512))
                } else if type.conforms(to: .mpeg4Movie) {
                    let asset = AVAsset(url: url)
                    let time = CMTimeMake(value: 0, timescale: 1)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    let (cgImage, _) = try await imageGenerator.image(at: time)
                    let img = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                    
                    guard let thumb = img.preparingThumbnail(maxWidth: 512) else {
                        throw Error.couldNotCreateImage
                    }
                    
                    thumbnail = thumb
                } else if type.conforms(to: .image) {
                    let data = try Data(contentsOf: url)
                    
                    guard let img = NSImage(data: data),
                          let thumb = img.preparingThumbnail(maxWidth: 512) else {
                        throw Error.couldNotCreateImage
                    }
                    
                    thumbnail = thumb
                } else {
                    throw Error.unsupportedContentType
                }
                
                cache[url] = thumbnail
                handler(.success(thumbnail))
            } catch {
                handler(.failure(error))
            }
        }
    }
}
