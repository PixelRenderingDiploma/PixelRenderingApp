//
//  UntilProcessingCompleteFilter.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Foundation

struct UntilProcessingCompleteFilter<Base>: AsyncSequence,
                                            AsyncIteratorProtocol where Base: AsyncSequence, Base.Element == DataTransferSession.Output {
    func makeAsyncIterator() -> UntilProcessingCompleteFilter {
        return self
    }

    typealias AsyncIterator = Self
    typealias Element = DataTransferSession.Output

    private let inputSequence: Base
    private var completed = false
    private var iterator: Base.AsyncIterator

    init(input: Base) where Base.Element == Element {
        inputSequence = input
        iterator = inputSequence.makeAsyncIterator()
    }

    mutating func next() async -> Element? {
        if completed {
            return nil
        }

        guard let nextElement = try? await iterator.next() else {
            completed = true
            return nil
        }

        if case .requestCompleted = nextElement {
            completed = true
        }
        if case .requestCancelled = nextElement {
            completed = true
        }
        if case .requestError = nextElement {
            completed = true
        }

        return nextElement
    }
}
