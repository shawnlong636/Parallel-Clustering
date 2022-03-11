//
//  Tests_ClusterModelPerformance.swift
//  Model Tests
//
//  Created by Shawn Long on 3/10/22.
//

import XCTest

class Tests_ClusterModelPerformance: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testPerformance1() throws {

        // Test 1
        let test1 = PerformanceTest(.DiscretePoints(dimmension: 3, size: 10_000))
        let model1 = try ClusterModel(data: test1.data, dimmension: test1.dimmension)
        printBenchmark(title: "Test 1") {
            do { try model1.cluster(count: 10) } catch { }
        }

        // Test 2
        let test2 = PerformanceTest(.DiscretePoints(dimmension: 5, size: 20_000))
        let model2 = try ClusterModel(data: test2.data, dimmension: test2.dimmension)
        printBenchmark(title: "Test 2") {
            do { try model2.cluster(count: 10) } catch { }
        }

        // Test 3
        let test3 = PerformanceTest(.DiscretePoints(dimmension: 2, size: 100_000))
        let model3 = try ClusterModel(data: test3.data, dimmension: test3.dimmension)
        printBenchmark(title: "Test 3") {
            do { try model3.cluster(count: 8) } catch { }
        }

        // Test 4
        let test4 = PerformanceTest(.Image(width: 250, Height: 250))
        let model4 = try ClusterModel(data: test4.data, dimmension: test4.dimmension)
        printBenchmark(title: "Test 4") {
            do { try model4.cluster(count: 8) } catch { }
        }

        // Test 5
        let test5 = PerformanceTest(.Image(width: 640, Height: 480))
        let model5 = try ClusterModel(data: test5.data, dimmension: test5.dimmension)
        printBenchmark(title: "Test 5") {
            do { try model5.cluster(count: 2) } catch { }
        }
    }

    func testTemp() {

    }
}
