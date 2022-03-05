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

    func testDimmension1Input() throws {

        var cluster1 = try ClusterModel(dimmension: 1)
        XCTAssertEqual(cluster1.data, [])
        XCTAssertEqual(cluster1.dimmension, 1)

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
