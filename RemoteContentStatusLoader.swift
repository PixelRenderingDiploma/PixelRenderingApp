//
//  RemoteContentStatusLoader.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-13.
//

import Foundation
import Combine

enum RemoteContentStatusLoaderError: Error {
    case cancelled
    case unauthorized
}

class RemoteContentStatusLoader {
    typealias Output = RenderingRequest
    
    let id: UUID
    let interval: TimeInterval
    
    weak var webApi: WebApi?
    
    private var refreshTask: Task<Void, Error>?
    
    @Published private(set) var request: Output = .empty
    
    init(id: UUID, webApi: WebApi, interval: TimeInterval = 5.0) {
        self.id = id
        self.webApi = webApi
        self.interval = interval
    }
    
    func start() {
        guard refreshTask?.isCancelled != false else {
            return
        }
        
        let idStr = id.uuidString.lowercased()
        
        refreshTask = Task {
            while request.status != .done || request.status != .error {
                try Task.checkCancellation()
                
                guard let webApi else {
                    throw RemoteContentStatusLoaderError.unauthorized
                }
                
                let data = try await webApi.getUserBlob(blobPath: "configs/requests/\(idStr).json")
                let request = try JSONDecoder().decode(RenderingRequest.self, from: data)
                
                self.request = request
                
                try await Task.sleep(nanoseconds: UInt64(self.interval * 1_000_000_000))
            }
        }
    }
    
    func cancel() {
        refreshTask?.cancel()
    }
}

extension RemoteContentStatusLoader: UpdateAggregatable {
    var updates: UntilProcessingCompleteFilter<Updates> {
        UntilProcessingCompleteFilter(input: $request.sequence) {
            switch $0.status {
            case .done, .error:
                true
            default:
                false
            }
        }
    }
}

protocol UpdateAggregatable {
    associatedtype Output
    typealias Updates = CombineAsyncPublsiher<Published<Output>.Publisher>
    
    var updates: UntilProcessingCompleteFilter<Updates> { get }
}

struct AnyUpdateAggregatable<Output>: UpdateAggregatable {
    var updates: UntilProcessingCompleteFilter<Updates>

    init<U: UpdateAggregatable>(_ aggregatable: U) where U.Output == Output {
        self.updates = aggregatable.updates
    }
}

class DynamicUpdateAggregator<Element> where Element: UpdateAggregatable {
    @Published var output: Element.Output
    var updates: CombineAsyncPublsiher<Published<Element.Output>.Publisher> {
        $output.sequence
    }
    
    private var aggragated = [UUID: AnyUpdateAggregatable<Element.Output>]()
    private var tasks = [UUID: Task<Void, Never>]()
    
    init(_ initialValue: Element.Output) {
        self.output = initialValue
    }
    
    func add(_ id: UUID, _ elem: Element) {
        guard aggragated[id] == nil else {
            return
        }
        
        let wrapped = AnyUpdateAggregatable(elem)
        aggragated[id] = wrapped
        
        let task = Task { [weak self] in
            for await output in wrapped.updates {
                self?.output = output
            }
            
            self?.aggragated.removeValue(forKey: id)
            self?.remove(task: id)
        }
        
        tasks[id] = task
    }
    
    private func remove(task: UUID) {
        tasks[task]?.cancel()
        tasks.removeValue(forKey: task)
    }
    
    private func cancelAll() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
