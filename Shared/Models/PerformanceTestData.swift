//
//  PerformanceTestData.swift
//  Parallel Clustering
//
//  Created by Shawn Long on 3/10/22.
//

import Foundation

enum DataType {
    case Image(width: Int, Height: Int)
    case DiscretePoints(dimmension: Int, size: Int)
}

class PerformanceTest {

    var dimmension: Int
    var size: Int
    var data: ContiguousArray<Double>

    init(_ data: DataType) {
        switch data {
        case .Image(let width, let height):
            self.dimmension = 6 // (r, g, b, a, x, y)

            self.size = width * height

            self.data = ContiguousArray<Double>(repeating: 0.0, count: self.dimmension * self.size)

            for pointIndex in 0 ..< self.size {
                for offset in 0 ..< self.dimmension {
                    self.data[self.dimmension * pointIndex + offset] = Double(Int.random(in: 0 ... 255))
                }
            }

        case .DiscretePoints(let dimmension, let size):
            self.dimmension = dimmension
            self.size = size
            self.data = ContiguousArray<Double>(repeating: 0.0, count: self.dimmension * self.size)

            for pointIndex in 0 ..< self.size {
                for offset in 0 ..< self.dimmension {
                    self.data[self.dimmension * pointIndex + offset] = Double.random(in: -1_000_000 ... 1_000_000)
                }
            }
        }
    }
}

