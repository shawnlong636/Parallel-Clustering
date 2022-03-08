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
        let test = TestData_Dim1Sample()
        let model = try ClusterModel(dimmension: test.dimmension)
        XCTAssertEqual(model.points, [])
        XCTAssertEqual(model.dimmension, 1)

        try model.loadData(test.data)
        XCTAssertEqual(model.points, test.data)

        var dist = 0.0
        for centroidIndex in 0..<model.centroids.count {
            for pointIndex in 0..<model.points.count {
                dist = try model.DistanceSquared(
                    pointIndex: pointIndex,
                    centroidIndex: centroidIndex)

                XCTAssertEqual(dist,
                               pow(test.centroids[centroidIndex]
                                - test.data[pointIndex], 2))
                XCTAssertEqual(dist,
                               pow(test.data[pointIndex]
                                - test.centroids[centroidIndex], 2))
            }
        }
        XCTAssertThrowsError(try ClusterModel(data: [0.0], dimmension: 2))
        XCTAssertNoThrow(try ClusterModel(data: [], dimmension: 3))
        XCTAssertThrowsError(try ClusterModel(dimmension: -1))

    }

    func testDimmensionN() throws {
        let test = TestData_DimNSample(dimmension: Int.random(in: 1 ..< 100))
        let model = try ClusterModel(data: test.data, dimmension: test.dimmension)
        model.centroids = test.centroids

        XCTAssertEqual(model.points, test.data)
        XCTAssertEqual(model.centroids, test.centroids)

        var dist = 0.0
        var actual_dist = 0.0
        for centroidIndex in 0 ..< model.centroids.count / model.dimmension {
            for pointIndex in 0 ..< model.points.count / model.dimmension {

                dist = try model.DistanceSquared(
                    pointIndex: pointIndex,
                    centroidIndex: centroidIndex)

                actual_dist = 0.0
                for offset in 0 ..< model.dimmension {
                    let point_subIndex = pointIndex * model.dimmension + offset
                    let centroid_subIndex = centroidIndex * model.dimmension + offset
                    actual_dist += pow(test.data[point_subIndex]
                                       - test.centroids[centroid_subIndex], 2)
                }

                XCTAssertEqual(dist, actual_dist)
            }
        }
        XCTAssertThrowsError(try model.cluster(count: 0))
    }

    func testSmallCluster() throws {
        let test = TestData_SmallCluster()
        let model = try ClusterModel(data: test.data, dimmension: test.dimmension)
        try model.cluster(count: test.clusterCount, initialCentroids: test.centroids)
        XCTAssertEqual(model.clusters, test.clusters)
    }

    func testLargeCluster() throws {
        let test = TestData_LargeCluster()
        let model = try ClusterModel(data: test.data, dimmension: test.dimmension)
        try model.cluster(count: test.clusterCount, initialCentroids: test.centroids)
        XCTAssertEqual(model.clusters, test.clusters)
    }

    func testHighDimmensionalCluster() throws {
        let test = TestData_HighDimmensionalCluster()
        let model = try ClusterModel(data: test.data, dimmension: test.dimmension)
        try model.cluster(count: test.clusterCount, initialCentroids: test.centroids)
        XCTAssertEqual(model.clusters, test.clusters)
    }

    func testLargeSingleCluster() throws {
        let test = TestData_LargeSingleCluster()
        let model = try ClusterModel(data: test.data, dimmension: test.dimmension)

        // Test 5 Times with different Initial Centroids
        for _ in 1 ... 5 {
            try model.cluster(count: test.clusterCount)
            XCTAssertEqual(test.clusters, model.clusters)
        }
    }

    func testEachPointIsCentroid() throws {
        let test = TestData_MaxClusters()
        let model = try ClusterModel(data: test.data, dimmension: test.dimmension)
        try model.cluster(count: test.clusterCount, initialCentroids: test.centroids)
        XCTAssertEqual(model.clusters, test.clusters)
    }

    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
        print("\n\n\n")

        let sample = TestData_MaxClusters()
        let model = try ClusterModel(data: sample.data, dimmension: sample.dimmension)


        printBenchmark(title: "Sample Cluster | \(sample.clusterCount) Clusters | \(sample.size) Points | \(sample.dimmension)-Dimmensional Space") {
            do {
                try model.cluster(count: sample.clusterCount, initialCentroids: sample.centroids)
            }
            catch {
                print("Error")
            }
        }

        print("\n\n\n")
    }
}
