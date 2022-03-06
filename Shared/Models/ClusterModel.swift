//
//  ClusterModel.swift
//  Parallel Clustering
//
//  Created by Shawn Long on 3/5/22.
//

import Foundation
import Benchmark

enum ClusterModelError: Error {
    case InvalidInputData(Details: String)
    case PointOutOfBounds(index: Int)
    case CentroidOutOfBounds(index: Int)
}

class ClusterModel {
    let dimmension: Int
    var points: [Double] = []
    var centroids: [Double] = []
    var sets: [[Double]] = []

    init(data: [Double] = [], dimmension: Int ) throws {

        guard dimmension >= 1 else {
            throw ClusterModelError.InvalidInputData(Details: "Dimmension must be 1 or greater.")
        }

        self.dimmension = dimmension
        try loadData(data)
    }

    func loadData(_ data: [Double]) throws {
        if data != [] {
            // Assert that the size of data array is multiple of the dimmensions
            guard data.count % self.dimmension == 0 else {
                throw ClusterModelError.InvalidInputData(Details: "Array must contain mutiples of \(dimmension).")
            }
        }
        self.points = data
    }

    /// This function returns the Euclidean Distance Squared given two points.
    ///
    /// - Parameter pointIndex: The index marking the beginning of a point in the data array.
    /// - Parameter centroidIndex: The index marking the beginning of a centroid in the centroids array.
    ///
    /// - Returns: The Euclidean Distance Squared between the two points in n-dimmensional space
    func DistanceSquared(pointIndex: Int, centroidIndex: Int) throws -> Double {

        // Assert Valid Point
        guard pointIndex >= 0 && pointIndex < points.count / dimmension else {
            throw ClusterModelError.PointOutOfBounds(index: pointIndex)
        }

        // Assert Valid Centroid
        guard centroidIndex >= 0 && centroidIndex < centroids.count / dimmension else {
            throw ClusterModelError.CentroidOutOfBounds(index: centroidIndex)
        }

        var total = 0.0

        for offset in 0..<dimmension {
            total += pow(points[pointIndex * dimmension + offset]
                         - centroids[centroidIndex * dimmension + offset], 2)
        }

        return total
    }
}
