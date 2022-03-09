//
//  ClusterModel.swift
//  Parallel Clustering
//
//  Created by Shawn Long on 3/5/22.
//

import Foundation

enum ClusterModelError: Error {
    case InvalidInputData(Details: String)
    case PointOutOfBounds(index: Int)
    case CentroidOutOfBounds(index: Int)
    case InvalidArgument(Details: String)
    case AsyncRequired
}

class ClusterModel: CustomStringConvertible {
    let dimmension: Int
    var pointCount: Int = 0

    // Contains the Raw Point Data
    var points: [Double] = []

    // Data Structures Used During Clustering
    var centroids: [Double] = []
    var sets: [[[Double]]] = []
    var clusters: [Int] = []

    var description: String {
        return """
        \(self.dimmension)-Dimmensional Cluster of \(self.pointCount) Data Points:
        Points: \(self.points)
        Centroids: \(self.centroids)
        Clusters: \(self.clusters)
        Sets: \(self.sets)
        """
    }

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
        self.pointCount = data.count / self.dimmension

        // Reset the Clustering Data Structures since data has been changed
        self.centroids = []
        self.sets = []
        self.clusters = []
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

    /// This function initializes the centroids array using random points.
    ///
    /// - Parameter count: The number of clusters to initialize.
    func initializeCentroids(count: Int, initialCentroids: [Double]?) {

        // Initialize clusters to all 0
        self.clusters = Array<Int>(repeating: 0, count: self.pointCount)

        if initialCentroids != nil {
            self.centroids = initialCentroids ?? []
        }  else {
            
            // Reserve size of the Centroids array
            self.centroids = Array<Double>(repeating: 0.0,
                                        count: count * self.dimmension)



            // Create unique list of points of length 'count'
            var pointIndices: [Int] = []

            var pointIndex: Int
            while pointIndices.count < count {
                pointIndex = Int.random(in: 0..<self.pointCount)
                if !pointIndices.contains(pointIndex) {
                    pointIndices.append(pointIndex)
                }
            }

            // Create the centroids
            for (centroidIndex, pointIndex) in pointIndices.enumerated() {
                for offset in 0..<self.dimmension {
                    self.centroids[centroidIndex * dimmension + offset] = self.points[pointIndex * dimmension + offset]
                }
            }
        }

    }

    /// This function iterates over points in the cluster model and assigns them to a cluster
    /// based on the nearest centroid.
    ///
    /// - Parameter clusterCount: The number of clusters being used for the current clustering
    func assignClusters(clusterCount: Int) throws {

//        // Initialize m empty arrays for each cluster, where m is the dimmension of the ClusterModel
//        self.sets = []
//        for index in 0 ..< clusterCount {
//            self.sets.append([])
//            for _ in 0 ..< self.dimmension {
//                self.sets[index].append([])
//            }
//        }

        for pointIndex in 0 ..< pointCount {
            var min_dist = Double.infinity

            for centroidIndex in 0 ..< clusterCount {
                let cur_dist = try DistanceSquared(pointIndex: pointIndex, centroidIndex: centroidIndex)
                if cur_dist < min_dist {
                    min_dist = cur_dist
                    self.clusters[pointIndex] = centroidIndex
                }
            }
//            let closestCentroid = self.clusters[pointIndex]
//
//            for offset in 0 ..< self.dimmension {
//                self.sets[closestCentroid][offset].append(
//                    self.points[pointIndex * self.dimmension + offset])
//            }
        }
    }

    func updateCentroids(clusterCount: Int) throws {
        for centroidIndex in 0 ..< clusterCount {
            let clusterSize = self.sets[centroidIndex][0].count
            for offset in 0 ..< self.dimmension {
                self.centroids[centroidIndex * self.dimmension + offset] =
                    self.sets[centroidIndex][offset].reduce(0.0, +) / Double(clusterSize)
            }
        }
    }

    func createSets(clusterCount: Int) {

        // Initialize empty array for each cluster
        self.sets = []
        for _ in 0 ..< clusterCount {
            self.sets.append([])
        }

        // Create sets by filtering clusters array
        for clusterIndex in 0 ..< clusterCount {

            // Get List of pointInidices from clusters where the cluster is the current cluster
              let pointIndices = self.clusters.indices.filter { self.clusters[$0] == clusterIndex }

            // Initialize each componenent array for the given cluster
            for _ in 0 ..< self.dimmension {
                self.sets[clusterIndex].append(Array<Double>(repeating: 0.0, count: pointIndices.count))
            }

            for offset in 0 ..< self.dimmension {
                for (setIndex, pointIndex) in pointIndices.enumerated() {
                    self.sets[clusterIndex][offset][setIndex] = self.points[pointIndex * self.dimmension + offset] // TODO: Fix index out of range error
                }
            }

        }

    }

    func cluster(count: Int, initialCentroids: [Double]? = nil) throws {

        // Validate Input
        guard count >= 1 else {
            throw ClusterModelError.InvalidArgument(Details: "Cluster count must be at least 1")
        }

        // Initialize centroids
        initializeCentroids(count: count, initialCentroids: initialCentroids)

        for _ in 0 ..< ProjectConstants.MAX_ITERATIONS {

            // Assign Data Points to the Nearest Centroid
            try assignClusters(clusterCount: count)

            createSets(clusterCount: count)

            // Update Centroid to be the Average of each Cluster
            try updateCentroids(clusterCount: count)
        }
    }

}

class ParallelClusterModel : ClusterModel {
    override func assignClusters(clusterCount: Int) throws {

        let groupSize = 10_000
        var pointIndex = 0

        let dispatchGroup = DispatchGroup()
        DispatchQueue.concurrentPerform(iterations: self.clusters.count / groupSize) { (groupIndex) in

            dispatchGroup.enter()
            for subIndex in 0 ..< groupSize {
                pointIndex = groupIndex * groupSize + subIndex

                var min_dist = Double.infinity

                for centroidIndex in 0 ..< clusterCount {
                    do {
                        let cur_dist = try self.DistanceSquared(pointIndex: pointIndex, centroidIndex: centroidIndex)
                        if cur_dist < min_dist {
                            min_dist = cur_dist
                            self.clusters[pointIndex] = centroidIndex
                        }
                    } catch {
                        print("Failed: \(error)")
                    }
                }

            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: DispatchQueue.main) { }
        dispatchGroup.wait()


        // Process the last group (size <= 1000)
        let start = (self.clusters.count / groupSize) * groupSize

        for pointIndex in start ..< self.clusters.count {
            var min_dist = Double.infinity

            for centroidIndex in 0 ..< clusterCount {
                do {
                    let cur_dist = try self.DistanceSquared(pointIndex: pointIndex, centroidIndex: centroidIndex)
                    if cur_dist < min_dist {
                        min_dist = cur_dist
                        self.clusters[pointIndex] = centroidIndex
                    }
                } catch {
                    print("Failed: \(error)")
                }
            }
        }
    }
}
