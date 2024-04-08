//
//  CombineAsyncPublisher.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Combine

struct CombineAsyncPublsiher<P>: AsyncSequence, AsyncIteratorProtocol where P: Publisher, P.Failure == Never {
    typealias Element = P.Output
    typealias AsyncIterator = CombineAsyncPublsiher<P>

    func makeAsyncIterator() -> Self {
        return self
    }
    
    private let stream: AsyncStream<P.Output>
    private var iterator: AsyncStream<P.Output>.Iterator
    private var cancellable: AnyCancellable?
    
    init(_ upstream: P, bufferingPolicy limit: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded) {
        var subscription: AnyCancellable?
        
        stream = AsyncStream<P.Output>(P.Output.self, bufferingPolicy: limit) { continuation in
            subscription = upstream
                .sink(receiveValue: { value in
                    continuation.yield(value)
                })
        }
        
        cancellable = subscription
        iterator = stream.makeAsyncIterator()
    }
    
    mutating func next() async -> P.Output? {
        await iterator.next()
    }
}

extension Publisher where Self.Failure == Never {
    var sequence: CombineAsyncPublsiher<Self> {
        CombineAsyncPublsiher(self)
    }
}
