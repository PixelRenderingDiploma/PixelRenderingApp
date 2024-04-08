//
//  AsyncOperation.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-04-06.
//

import Foundation

class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.pixelrenderer.asyncoperation", attributes: .concurrent)

    override var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting = false
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    override func start() {
        guard !isCancelled else {
           finish()
           return
       }
        
        isFinished = false
        isExecuting = true
        
        main()
    }
    
    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

final class AsyncBlockOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.pixelrenderer.asyncoperation", attributes: .concurrent)

    override var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting = false
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var block: () async throws -> ()
    
    init(_ block: @escaping () async throws -> ()) {
        self.block = block
    }

    override func start() {
        guard !isCancelled else {
           finish()
           return
       }
        
        isFinished = false
        isExecuting = true
        
        main()
    }
    
    override func main() {
        Task {
            try? await self.block()
            finish()
        }
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}
