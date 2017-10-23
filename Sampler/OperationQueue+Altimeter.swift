import Foundation

extension OperationQueue {
    static let AltimeterQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return queue;
    }()
}
