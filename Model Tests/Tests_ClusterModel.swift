//
//  Tests_ClusterModel.swift
//  Model Tests
//
//  Created by Shawn Long on 3/5/22.
//

import XCTest
@testable import Parallel_Clustering
import SwiftUI

class Tests_ClusterModel: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testDimmension1() throws {

        // Test Initializing Empty Cluster in 1-Dimmensional Space
        let cluster1 = try ClusterModel(dimmension: 1)
        XCTAssertEqual(cluster1.points, [])
        XCTAssertEqual(cluster1.dimmension, 1)

        // Attempt to load existing data into cluster
        let points = (0..<1_000).map {_ in Double.random(in: -1_000...1_000)}

        try cluster1.loadData(points)

        XCTAssertEqual(cluster1.points, points)

        // Manually assign centroids
        cluster1.centroids = (0..<15).map {_ in Double.random(in: -1_000...1_000)}

        // Test Distance between all points and all centroids
        var dist = 0.0
        for centroidIndex in 0..<cluster1.centroids.count {
            for pointIndex in 0..<cluster1.points.count {
                dist = try cluster1.DistanceSquared(
                    pointIndex: pointIndex,
                    centroidIndex: centroidIndex)

                XCTAssertEqual(dist,
                               pow(cluster1.centroids[centroidIndex]
                                - cluster1.points[pointIndex], 2))
                XCTAssertEqual(dist,
                               pow(cluster1.points[pointIndex]
                                - cluster1.centroids[centroidIndex], 2))
            }
        }

        XCTAssertThrowsError(try ClusterModel(data: [0.0], dimmension: 2))
        XCTAssertNoThrow(try ClusterModel(data: [], dimmension: 3))
        XCTAssertThrowsError(try ClusterModel(dimmension: -1))
    }

    func testDimmensionN() throws {
        let dimmension = Int.random(in: 1..<20)

        let arr_size: Int = 10_000 * dimmension
        let points = (0..<arr_size).map {_ in Double.random(in: -100_000_000...100_000_000)}


        let centroids = (0..<(100 * dimmension)).map {_ in Double.random(in: -100_000_000...100_000_000)}
        let cluster = try ClusterModel(data: points, dimmension: dimmension)
        cluster.centroids = centroids

        XCTAssertEqual(cluster.points, points)
        XCTAssertEqual(cluster.centroids, centroids)

        // Test Distance Between Every Point and Centroid in N-Dimmensional Space

        var dist = 0.0
        var actual_dist = 0.0
        for centroidIndex in 0..<cluster.centroids.count / cluster.dimmension {
            for pointIndex in 0..<cluster.points.count / cluster.dimmension {

                dist = try cluster.DistanceSquared(
                    pointIndex: pointIndex,
                    centroidIndex: centroidIndex)

                actual_dist = 0.0
                for offset in 0..<cluster.dimmension {
                    let point_subIndex = pointIndex * cluster.dimmension + offset
                    let centroid_subIndex = centroidIndex * cluster.dimmension + offset
                    actual_dist += pow(cluster.points[point_subIndex]
                                       - cluster.centroids[centroid_subIndex], 2)
                }

                XCTAssertEqual(dist, actual_dist)
            }
        }

        XCTAssertThrowsError(try cluster.cluster(count: 0))

    }

    func testSmallCluster() throws {
        let dimmension = 2

        var dataCluster1: [Double] = []
        let cluster1Size = Int.random(in: 1 ... 7)
        for _ in 0 ..< cluster1Size {
            dataCluster1.append(Double.random(in: -2.5 ... -0.5))
            dataCluster1.append(Double.random(in: 1.1 ... 1.5))
        }

        var dataCluster2: [Double] = []
        let cluster2Size = Int.random(in: 1 ... 7)
        for _ in 0 ..< cluster2Size {
            dataCluster2.append(Double.random(in: 3.8 ... 11.2))
            dataCluster2.append(Double.random(in: -8.3 ... -3.2))
        }

        let combinedData = dataCluster1 + dataCluster2
        print(combinedData)
        let model1 = try ClusterModel(data: combinedData, dimmension: dimmension)
        let initialCentroids = [-1.5, 1.3, 4.075, 5.75]

        try model1.cluster(count: 2, initialCentroids: initialCentroids)

        for index in 0 ..< cluster1Size {
            XCTAssertEqual(model1.clusters[index], 0)
        }

        for index in 0 ..< cluster2Size {
            XCTAssertEqual(model1.clusters[cluster1Size + index], 1)
        }

    }


    func testLargeCluster() throws {
        let dimmension = 3

        // Points near (-1.5, -1, -3.5)
        var dataCluster1: [Double] = []
        let cluster1Size = Int.random(in: 1 ... 10_000)
        for _ in 0 ..< cluster1Size {
            dataCluster1.append(Double.random(in: -2.5 ... -0.5))
            dataCluster1.append(Double.random(in: -1.5 ... -0.5))
            dataCluster1.append(Double.random(in: -5.4 ... -1.3))
        }

        // Points near (-1.5, 10.0, -1.5)
        var dataCluster2: [Double] = []
        let cluster2Size = Int.random(in: 1 ... 10_000)
        for _ in 0 ..< cluster2Size {
            dataCluster2.append(Double.random(in: -3.1245 ... 0.0))
            dataCluster2.append(Double.random(in: 7.123456 ... 14.987))
            dataCluster2.append(Double.random(in: -2.9257 ... -1.0001))
        }

        // points near (3.0, -30.0, 0.0)
        var dataCluster3: [Double] = []
        let cluster3Size = Int.random(in: 1 ... 10_000)
        for _ in 0 ..< cluster3Size {
            dataCluster3.append(Double.random(in: 1.743 ... 6.543))
            dataCluster3.append(Double.random(in: -35.1243 ... -27.00))
            dataCluster3.append(Double.random(in: -0.2 ... 0.2))
        }


        // Points near (40.0, 30.0, 20.0)
        var dataCluster4: [Double] = []
        let cluster4Size = Int.random(in: 1 ... 10_000)
        for _ in 0 ..< cluster4Size {
            dataCluster4.append(Double.random(in: 35.0 ... 45.0))
            dataCluster4.append(Double.random(in: 25.0 ... 35.00))
            dataCluster4.append(Double.random(in: 15.0 ... 25.00))
        }


        let combinedData = dataCluster1 + dataCluster2 + dataCluster3 + dataCluster4


        let model = try ClusterModel(data: combinedData, dimmension: dimmension)
        let initialCentroids = [-1.5, -1, -3.5, -1.5, 10.0, -1.5, 3.0, -30.0, 0.0, 40.0, 30.0, 20.0]

        try model.cluster(count: 4, initialCentroids: initialCentroids)

        for index in 0 ..< cluster1Size {
            XCTAssertEqual(model.clusters[index], 0)
        }

        for index in 0 ..< cluster2Size {
            XCTAssertEqual(model.clusters[cluster1Size + index], 1)
        }

        for index in 0 ..< cluster3Size {
            XCTAssertEqual(model.clusters[cluster1Size + cluster2Size + index], 2)
        }

        for index in 0 ..< cluster4Size {
            XCTAssertEqual(model.clusters[cluster1Size + cluster2Size + cluster3Size + index], 3)
        }
    }

    func testHighDimmensionalCluster() throws {
        let dimmension = 1000


        let cluster1Size = Int.random(in: 1_000 ... 5_000)
        var cluster1Data: [Double] = []
        for _ in 0 ..< cluster1Size {
            for _ in 0 ..< dimmension {
                cluster1Data.append(Double.random(in: -1200.0 ... -1000.0))
            }
        }

        let cluster2Size = Int.random(in: 1000 ... 5_000)
        var cluster2Data: [Double] = []
        for _ in 0 ..< cluster2Size {
            for _ in 0 ..< dimmension {
                cluster2Data.append(Double.random(in: 2400.0 ... 2800.0))
            }
        }

        let combinedData = cluster1Data + cluster2Data
        let model = try ClusterModel(data: combinedData, dimmension: dimmension)
        let initialcentroids = Array<Double>(repeating: -1100.0, count: dimmension)
                                + Array<Double>(repeating: 2600.0, count: dimmension)


        try model.cluster(count: 2, initialCentroids: initialcentroids)


        for index in 0 ..< cluster1Size {
            XCTAssertEqual(model.clusters[index], 0)
        }

        for index in 0 ..< cluster2Size {
            XCTAssertEqual(model.clusters[cluster1Size + index], 1)
        }

    }

    func testSingleCluster() throws {

        for _ in 0 ..< 5 { // Repeat 5 Times since Initializer picks a random point to initialize from each time
            let dataSet = (0 ..< 300_000).map { _ in Double.random(in: -1_000_000.00 ... 1_000_000.00)}
            let model = try ClusterModel(data: dataSet, dimmension: 3)
            try model.cluster(count: 1)

            for cluster in model.clusters { XCTAssertEqual(cluster, 0) }
        }
    }

    func testEachPointIsCentroid() throws {

        for _ in 0 ..< 5 { // Repeat 5 Times since Initializer picks a random point to initialize from each time
            let dataSet = (0 ..< 300_000).map { _ in Double.random(in: -1_000_000.00 ... 1_000_000.00)}
            let model = try ClusterModel(data: dataSet, dimmension: 3)
            try model.cluster(count: 1)

            for cluster in model.clusters { XCTAssertEqual(cluster, 0) }
        }
    }

    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
        print("\n\n\n")

        /* Create the model for testing */

        let dimmension = 1000

        let cluster1Size = 5_000
        var cluster1Data: [Double] = []
        for _ in 0 ..< cluster1Size {
            for _ in 0 ..< dimmension {
                cluster1Data.append(Double.random(in: -1200.0 ... -1000.0))
            }
        }

        let cluster2Size = 5_000
        var cluster2Data: [Double] = []
        for _ in 0 ..< cluster2Size {
            for _ in 0 ..< dimmension {
                cluster2Data.append(Double.random(in: 2400.0 ... 2800.0))
            }
        }

        let combinedData = cluster1Data + cluster2Data
        let model = try ClusterModel(data: combinedData, dimmension: dimmension)
        let initialcentroids = Array<Double>(repeating: -1100.0, count: dimmension)
                                + Array<Double>(repeating: 2600.0, count: dimmension)


        printBenchmark(title: "Naive Sequential Cluster | 10k Points, 1000-Dimmensional Space") {
            do {
                try model.cluster(count: 2, initialCentroids: initialcentroids)
            }
            catch {
                print("Error")
            }
        }

        print("\n\n\n")
    }
}
