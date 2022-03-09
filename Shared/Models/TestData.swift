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

struct TestData_LargeSingleCluster: TestData {
    var data: [Double] = (0 ..< 300_000).map { _ in Double.random(in: -1_000_000.00 ... 1_000_000.00)}
    var centroids: [Double] = [0.0, 0.0, 0.0]
    var dimmension: Int = 3
    var clusterCount: Int = 1
    var size: Int = 100_000
    var clusters: [Int]? = Array<Int>(repeating: 0, count: 100_000)
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

final class TestData_LargeCluster: TestData {
    var data: [Double]

    var centroids: [Double]

    let dimmension: Int = 3

    var clusterCount: Int = 4

    var size: Int

    var clusters: [Int]?

    init() {
        let pointsPerCluster: Int = 20_000
        self.size = self.clusterCount * pointsPerCluster

        // Points near (-1.5, -1, -3.5)
        var dataCluster1: [Double] = []
        for _ in 0 ..< pointsPerCluster {
            dataCluster1.append(Double.random(in: -2.5 ... -0.5))
            dataCluster1.append(Double.random(in: -1.5 ... -0.5))
            dataCluster1.append(Double.random(in: -5.4 ... -1.3))
        }

        // Points near (-1.5, 10.0, -1.5)
        var dataCluster2: [Double] = []
        for _ in 0 ..< pointsPerCluster {
            dataCluster2.append(Double.random(in: -3.1245 ... 0.0))
            dataCluster2.append(Double.random(in: 7.123456 ... 14.987))
            dataCluster2.append(Double.random(in: -2.9257 ... -1.0001))
        }

        // points near (3.0, -30.0, 0.0)
        var dataCluster3: [Double] = []
        for _ in 0 ..< pointsPerCluster {
            dataCluster3.append(Double.random(in: 1.743 ... 6.543))
            dataCluster3.append(Double.random(in: -35.1243 ... -27.00))
            dataCluster3.append(Double.random(in: -0.2 ... 0.2))
        }

        // Points near (40.0, 30.0, 20.0)
        var dataCluster4: [Double] = []
        for _ in 0 ..< pointsPerCluster {
            dataCluster4.append(Double.random(in: 35.0 ... 45.0))
            dataCluster4.append(Double.random(in: 25.0 ... 35.00))
            dataCluster4.append(Double.random(in: 15.0 ... 25.00))
        }

        self.data = dataCluster1 + dataCluster2 + dataCluster3 + dataCluster4

        self.centroids = [-1.5, -1, -3.5, -1.5, 10.0, -1.5, 3.0, -30.0, 0.0, 40.0, 30.0, 20.0]


        self.clusters = []

        for index in 0 ..< clusterCount {
            self.clusters! += Array<Int>(repeating: index, count: pointsPerCluster)
        }
    }
}

final class TestData_HighDimmensionalCluster: TestData {
    var data: [Double]

    var centroids: [Double]

    var dimmension: Int = 1_000

    var clusterCount: Int = 2

    var size: Int

    var clusters: [Int]?

    init() {
        let pointsPerCluster = 5_000
        self.size = self.clusterCount * pointsPerCluster

        // if x in range(-1200 to -1000), then each point = (x, x, x, x, ... , x) for dimm times
        var cluster1Data: [Double] = []
        for _ in 0 ..< pointsPerCluster {
            for _ in 0 ..< dimmension {
                cluster1Data.append(Double.random(in: -1200.0 ... -1000.0))
            }
        }

        // if y in range(2400 to 2800), then each point = (y, y, y, y, ... , y) for dimm times
        var cluster2Data: [Double] = []
        for _ in 0 ..< pointsPerCluster {
            for _ in 0 ..< dimmension {
                cluster2Data.append(Double.random(in: 2400.0 ... 2800.0))
            }
        }

        self.data = cluster1Data + cluster2Data
        self.centroids = Array<Double>(repeating: -1100.0, count: dimmension)
                        + Array<Double>(repeating: 2600.0, count: dimmension)

        self.clusters = Array<Int>(repeating: 0, count: pointsPerCluster)
                        + Array<Int>(repeating: 1, count: pointsPerCluster)
    }
}

final class TestData_MaxClusters: TestData {
    var data: [Double] = (0 ..< 3_000).map { _ in Double.random(in: -1_000_000.00 ... 1_000_000.00)}
    var centroids: [Double]
    var dimmension: Int = 3
    var clusterCount: Int = 1_000
    var size: Int = 1_000
    var clusters: [Int]?

    init() {
        self.centroids = data
        self.clusters = Array(0 ..< self.clusterCount)
    }
}
