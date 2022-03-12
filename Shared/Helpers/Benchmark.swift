//
//  Benchmark.swift
//  Parallel Clustering
//
//  Created by Shawn Long on 3/5/22.
//

import Foundation

func printBenchmark(title: String, operation: () -> ()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("\n\(title) | Time elapsed: \(timeElapsed) seconds\n")
}

func printBenchmark(title: String, operation: () async -> ()) async {
    let startTime = CFAbsoluteTimeGetCurrent()
    await operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("\n\(title) | Time elapsed: \(timeElapsed) seconds\n")
}

func Benchmark(title: String, operation: () -> ()) -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("\n\(title) | Time elapsed: \(timeElapsed) seconds\n")
    return Double(timeElapsed)
}

func Benchmark(title: String, operation: () async -> ()) async -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()
    await operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("\n\(title) | Time elapsed: \(timeElapsed) seconds\n")
    return Double(timeElapsed)
}

enum ProjectConstants {
    static let MAX_ITERATIONS: Int = 25
}
