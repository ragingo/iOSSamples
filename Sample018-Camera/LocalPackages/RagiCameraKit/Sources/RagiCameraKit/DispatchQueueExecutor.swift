//
//  DispatchQueueExecutor.swift
//  RagiCameraKit
//
//  Created by ragingo on 2024/12/15.
//

import Foundation

// DispatchSerialQueue のイニシャライザは iOS17.0+
// DispatchSerialQueue の asUnownedSerialExecutor() が使えないから、
// 自分で SerialExecutor を実装する必要あり
final class DispatchQueueExecutor: SerialExecutor {
    private let queue: DispatchQueue

    init(queue: DispatchQueue) {
        self.queue = queue
    }

    convenience init(label: String) {
        self.init(queue: DispatchQueue(label: label))
    }

    func enqueue(_ job: UnownedJob) {
        let executor = asUnownedSerialExecutor()
        queue.async {
            job.runSynchronously(on: executor)
        }
    }

    // 注意: asUnownedSerialExecutor() のデフォルト実装が使えるのは iOS17.0+
    // 参考: https://github.com/swiftlang/swift/blob/dda7c8139646395fa09b01fea4cefc65862b8cf8/stdlib/public/Concurrency/Executor.swift#L291-L296
    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}
