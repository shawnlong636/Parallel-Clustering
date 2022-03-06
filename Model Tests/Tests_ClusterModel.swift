//
//  Tests_ClusterModel.swift
//  Model Tests
//
//  Created by Shawn Long on 3/5/22.
//

import XCTest
@testable import Parallel_Clustering

class Tests_ClusterModel: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testDimmension1() throws {

        // Test Initializing Empty Cluster in 1-Dimmensional Space
        var cluster1 = try ClusterModel(dimmension: 1)
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

        // TODO: Test Invalid Arguments
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

        // TODO: Test Invalid Arguments

    }

    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
        print("\n\n\n")
        var arr = Array(repeating: 0.0, count: 10_000_000)

        printBenchmark(title: "Array Modify") {
            
        }

        print("\n\n\n")
    }

}
