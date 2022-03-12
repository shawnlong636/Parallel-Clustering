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
        let model1 = try ImprovedClusterModel(data: test1.data, dimmension: test1.dimmension)

        var val = 0.0
        for _ in 1...5 {
            val += Benchmark(title: "Test 1") { do { try model1.cluster(count: 10) } catch { } }
        }
        print("Test 1 Average: \(val / 5.0) seconds")

    }

    func testPerformance2() throws {

        // Test 2
        let test2 = PerformanceTest(.DiscretePoints(dimmension: 5, size: 20_000))
        let model2 = try ImprovedClusterModel(data: test2.data, dimmension: test2.dimmension)

        var val = 0.0

        for _ in 1...5 {
            val += Benchmark(title: "Test 2") { do { try model2.cluster(count: 10) } catch { } }
        }
        print("Test 2 Average: \(val / 5.0) seconds")
    }

    func testPerformance3() throws {

        // Test 3
        let test3 = PerformanceTest(.DiscretePoints(dimmension: 2, size: 100_000))
        let model3 = try ImprovedClusterModel(data: test3.data, dimmension: test3.dimmension)

        var val = 0.0

        for _ in 1...5 {
            val += Benchmark(title: "Test 3") { do { try model3.cluster(count: 8) } catch { } }
        }
        print("Test 3 Average: \(val / 5.0) seconds")
    }

    func testPerformance4() throws {

        // Test 4
        let test4 = PerformanceTest(.Image(width: 250, Height: 250))
        let model4 = try ImprovedClusterModel(data: test4.data, dimmension: test4.dimmension)

        var val = 0.0
        for _ in 1...5 {
            val += Benchmark(title: "Test 4") { do { try model4.cluster(count: 8) } catch { } }
        }
        print("Test 4 Average: \(val / 5.0) seconds")

    }

    func testPerformance5() throws {

        // Test 5
        let test5 = PerformanceTest(.Image(width: 640, Height: 480))
        let model5 = try ImprovedClusterModel(data: test5.data, dimmension: test5.dimmension)

        var val = 0.0
        for _ in 1...5 {
            val += Benchmark(title: "Test 5") { do { try model5.cluster(count: 2) } catch { } }
        }
        print("Test 5 Average: \(val / 5.0) seconds")
    }

}
