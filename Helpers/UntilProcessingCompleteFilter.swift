//
//  UntilProcessingCompleteFilter.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Foundation

protocol SequenceFilter {
    associatedtype CaseType
    
    var isCompletionCase: Bool { get }
}

struct AnySequenceFilter {
    private let _isCompletionCase: () -> Bool

    init<Filter: SequenceFilter>(_ filter: Filter) {
        _isCompletionCase = { filter.isCompletionCase }
    }

    var isCompletionCase: Bool {
        _isCompletionCase()
    }
}

struct UntilProcessingCompleteFilter<Base>: AsyncSequence,
                                            AsyncIteratorProtocol where Base: AsyncSequence {
    func makeAsyncIterator() -> UntilProcessingCompleteFilter {
        return self
    }

    typealias AsyncIterator = Self
    typealias Element = Base.Element

    private let inputSequence: Base
    private var completed = false
    private var iterator: Base.AsyncIterator
    private let predicate: (Base.Element) -> Bool

    init(input: Base, completionPredicate: @escaping (Base.Element) -> Bool) {
        inputSequence = input
        predicate = completionPredicate
        iterator = inputSequence.makeAsyncIterator()
    }

    mutating func next() async -> Base.Element? {
        if completed {
            return nil
        }

        guard let nextElement = try? await iterator.next() else {
            completed = true
            return nil
        }

        if predicate(nextElement) {
            completed = true
        }

        return nextElement
    }
}
