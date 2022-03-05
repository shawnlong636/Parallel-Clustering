//
//  ClusterModel.swift
//  Parallel Clustering
//
//  Created by Shawn Long on 3/5/22.
//

import Foundation
import Benchmark

enum ClusterModelError: Error {
    case InvalidInputData
    case PointOutOfBounds(index: Int)
    case CentroidOutOfBounds(index: Int)
}

class ClusterModel {
    let dimmension: Int
    var data: [Double]
    var centroids: [Double] = []
    var sets: [[Double]] = []

    init(data: [Double] = [], dimmension: Int ) throws {

        if data != [] {
            // Assert that the size of data array is multiple of the dimmensions
            guard data.count % dimmension != 0 else {
                throw ClusterModelError.InvalidInputData
            }
        }



        self.data = data
        self.dimmension = dimmension
    }

    /// This function returns the Euclidean Distance Squared given two points.
    ///
    /// - Parameter pointIndex: The index marking the beginning of a point in the data array.
    /// - Parameter centroidIndex: The index marking the beginning of a centroid in the centroids array.
    ///
    /// - Returns: The Euclidean Distance Squared between the two points in n-dimmensional space
    func DistanceSquared(pointIndex: Int, centroidIndex: Int) throws -> Double {

        // Assert Valid Point
        guard pointIndex >= 0 && pointIndex % dimmension == 0 && pointIndex < data.count else {
            throw ClusterModelError.PointOutOfBounds(index: pointIndex)
        }

        // Assert Valid Centroid
        guard centroidIndex >= 0 && centroidIndex % dimmension == 0 && centroidIndex < centroids.count else {
            throw ClusterModelError.CentroidOutOfBounds(index: centroidIndex)
        }

        return 0.0
    }
}
