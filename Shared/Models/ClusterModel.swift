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
    var points: ContiguousArray<Double> = ContiguousArray<Double>()

    // Data Structures Used During Clustering
    var centroids: ContiguousArray<Double> = ContiguousArray<Double>()
    var sets: [[[Double]]] = []
    var clusters: ContiguousArray<Int> = ContiguousArray<Int>()

    var description: String {
        return """
        \(self.dimmension)-Dimmensional Cluster of \(self.pointCount) Data Points:
        Points: \(self.points)
        Centroids: \(self.centroids)
        Clusters: \(self.clusters)
        Sets: \(self.sets)
        """
    }

    init(data: ContiguousArray<Double> = ContiguousArray<Double>(), dimmension: Int ) throws {

        guard dimmension >= 1 else {
            throw ClusterModelError.InvalidInputData(Details: "Dimmension must be 1 or greater.")
        }

        self.dimmension = dimmension
        try loadData(data)
    }

    func loadData(_ data: ContiguousArray<Double>) throws {
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

    /// This function returns the Euclidean Distance given two points.
    ///
    /// - Parameter pointIndex: The index marking the beginning of a point in the data array.
    /// - Parameter centroidIndex: The index marking the beginning of a centroid in the centroids array.
    ///
    /// - Returns: The Euclidean Distance between the two points in n-dimmensional space
    func Distance(pointIndex: Int, centroidIndex: Int) throws -> Double {

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
    func initializeCentroids(count: Int, initialCentroids: ContiguousArray<Double>?) {

        // Initialize clusters to all 0
        self.clusters = ContiguousArray<Int>(repeating: 0, count: self.pointCount)

        if initialCentroids != nil {
            self.centroids = initialCentroids ?? ContiguousArray<Double>()
        }  else {
            
            // Reserve size of the Centroids array
            self.centroids = ContiguousArray<Double>(repeating: 0.0,
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
    func assignClusters(clusterCount: Int) throws -> Bool {

        var changed = false

        for pointIndex in 0 ..< pointCount {
            var min_dist = Double.infinity

            let prevCluster = self.clusters[pointIndex]

            for centroidIndex in 0 ..< clusterCount {
                let cur_dist = try Distance(pointIndex: pointIndex, centroidIndex: centroidIndex)
                if cur_dist < min_dist {
                    min_dist = cur_dist
                    self.clusters[pointIndex] = centroidIndex
                }
            }

            if prevCluster != self.clusters[pointIndex] {
                changed = true
            }
        }
        return changed
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
                    self.sets[clusterIndex][offset][setIndex] = self.points[pointIndex * self.dimmension + offset] 
                }
            }
        }
    }

    func cluster(count: Int, initialCentroids: ContiguousArray<Double>? = nil) throws {

        // Validate Input
        guard count >= 1 else {
            throw ClusterModelError.InvalidArgument(Details: "Cluster count must be at least 1")
        }

        // Initialize centroids
        initializeCentroids(count: count, initialCentroids: initialCentroids)

        var changed = true
        var iteration = 0

        while changed {


            // Assign Data Points to the Nearest Centroid
            changed = try assignClusters(clusterCount: count)

            createSets(clusterCount: count)

            // Update Centroid to be the Average of each Cluster
            try updateCentroids(clusterCount: count)
            iteration += 1
        }
    }

}

class ImprovedClusterModel: ClusterModel {

    // Instead of the Naive Random points, use Scrambled Midpoints
    override func initializeCentroids(count: Int, initialCentroids: ContiguousArray<Double>?) {
        // Initialize clusters to all 0
        self.clusters = ContiguousArray<Int>(repeating: 0, count: self.pointCount)

        if initialCentroids != nil {
            self.centroids = initialCentroids ?? ContiguousArray<Double>()
        }  else {

            // Reserve size of the Centroids array
            self.centroids = ContiguousArray<Double>(repeating: 0.0,
                                        count: count * self.dimmension)



            // This array is being used for two purposes
            // First, it will be used to store the min/max of each feature across all points
            // Then, in a second pass, the arary will be updated to store the min vlaue and
            // the partitions size for each feature. This can be use to extrapolate medians
            // without actually storing all of the medians individually

            var auxiliary = ContiguousArray<Double>(repeating: 0.0, count: 2 * self.dimmension)

            // Pass 1: Store Min/Max Values for each dimmension
            for pointIndex in 0 ..< self.pointCount {
                for offset in 0 ..< self.dimmension {
                    // Store the min value
                    auxiliary[2 * offset] = min(auxiliary[2 * offset], self.points[self.dimmension * pointIndex + offset])

                    // Store the max value
                    auxiliary[2 * offset + 1] = max(auxiliary[2 * offset + 0], self.points[self.dimmension * pointIndex + offset])
                }
            }

            // Pass 2: Store the partition size and min
            var min = 0.0
            var max = 0.0
            for offset in 0 ..< self.dimmension {
                min = auxiliary[2 * offset]
                max = auxiliary[2 * offset + 1]

                // Stores the size of each partition by dividing range by k
                auxiliary[2 * offset + 1] = (max - min) / Double(count)
            }

            // Pass 3: Create the centroids from scrambled partitions

            var randomPartition = 0
            var median: Double = 0.0
            var partSize: Double = 0.0
            for centroidIndex in 0 ..< count {
                for offset in 0 ..< self.dimmension {
                    randomPartition = Int.random(in: 0 ..< count)
                    min = auxiliary[2 * offset]
                    partSize = auxiliary[2 * offset + 1]
                    median = min + Double(randomPartition) * partSize
                    self.centroids[centroidIndex * self.dimmension + offset] = median
                }
            }

        }
    }

}
