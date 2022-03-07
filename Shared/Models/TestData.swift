//
//  TestData.swift
//  Parallel Clustering
//
//  Created by Shawn Long on 3/6/22.
//

import Foundation

protocol TestData {
    var data: [Double] {get}
    var centroids: [Double] {get}
    var dimmension: Int {get}
    var clusterCount: Int {get}
    var size: Int {get}
    var clusters: [Int]? {get}
}

struct TestData_Dim1Sample: TestData {
    var clusterCount = 15
    var size: Int = 1_000
    let dimmension = 1
    let data = (0 ..< 1_000).map {_ in Double.random(in: -1_000...1_000)}
    let centroids = (0 ..< 15).map {_ in Double.random(in: -1_000...1_000)}
    let clusters: [Int]? = nil
}

final class TestData_DimNSample: TestData {
    var data: [Double]
    var centroids: [Double]
    var dimmension: Int
    var clusterCount: Int = 100
    var size: Int = 10_000
    var clusters: [Int]? = nil

    init(dimmension: Int) {

        self.dimmension = dimmension

        self.data = (0 ..< (size * dimmension)).map {_ in
            Double.random(in: -100_000_000 ... 100_000_000)
        }

        self.centroids = (0 ..< (100 * dimmension)).map {_ in
            Double.random(in: -100_000_000 ... 100_000_000)
        }
    }
}

final class TestData_SmallCluster: TestData {
    let data: [Double]

    var centroids: [Double]

    let dimmension: Int = 2

    var clusterCount: Int = 2

    let size: Int = 14

    var clusters: [Int]?

    init() {
        var dataCluster1: [Double] = []
        let cluster1Size = 7
        for _ in 0 ..< cluster1Size {
            dataCluster1.append(Double.random(in: -2.5 ... -0.5))
            dataCluster1.append(Double.random(in: 1.1 ... 1.5))
        }

        var dataCluster2: [Double] = []
        let cluster2Size = 7
        for _ in 0 ..< cluster2Size {
            dataCluster2.append(Double.random(in: 3.8 ... 11.2))
            dataCluster2.append(Double.random(in: -8.3 ... -3.2))
        }

        self.data = dataCluster1 + dataCluster2

        self.centroids = [-1.5, 1.3, 4.075, 5.75]

        self.clusters = Array<Int>(repeating: 0, count: 7)
                        + Array<Int>(repeating: 1, count: 7)
    }
}
