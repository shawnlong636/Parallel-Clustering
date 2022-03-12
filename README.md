#  Parallel Clustering: Optimized K-Means in Swift

Shawn Long

[Github](https://github.com/shawnlong636/Parallel-Clustering)

## Introduction

Parallel Clustering was originally meant to be a demo application for an optimized, parallel implementation of K-Means clustering in Swift. In reality, this title is misleading because I have concluded that the kind of parallelism I hoped to achieve is not realistically possible in the current state of Swift. Nonetheless, this project does provide a general framework for the K-Means clustering with a few optimizations.

### The Trouble with K-Means Clustering

In practical terms, there were quite a few roadblocks that had to be overcome to complete this project. On the one hand, K-Means clustering is not a terribly difficult algorithm. The naive implementation does not make significant use of complex data structures, and the overall implementation is basically iterative. The real difficulty with K-Means is optimizing it. Fundamentally, K-Means is an NP-Hard optimization problem<sup>**[1](https://cseweb.ucsd.edu/~avattani/papers/kmeans_hardness.pdf)**</sup>. Unlike many other algorithms, there isn't a generally accepted *correct* answer on how to cluster any given data set. It depends on the chosen methods to calculate distance between a given centroid. However because the naive implementation reuqires choosing random starting points, there is an element of non-detereminism which makes runtime for any one test vary dramatically. In regards to analyzing runtime and determining where improvements can be made, this is a major hinderance. Still there, are quiet a few optimizations that can be made in general which are proven to improve performance.

### Challenges Implenting in Swift

As I was considering implementing this algorithm using Swift, I discovered that a recent version of Swift (version 5.5) introduced some new keywords which greatly improved the ease of writing concurrent software in Swift. What I didn't realize at this time was that the new keywords, which equate quite closely to *fork* and *join* int he dynamic multithreading model, don't actually run in parallel. They allow code to be written concurrently, but not actually in parallel. That's not to say that Swift doesn't support parllelism though. There is indeed a single provided method for a parallel for loop. Unforuntately though, being a higher level language than C++ and with a strong emphasis on writing *safe* code, the language does not allow accessing different indices in an array as separate memory locations. Because of this, parallel array modifications actually end up taking significantly longer than the sequenetial versions because, in essence, Swift puts a lock on the array so that no two threads can modify it at the same time, even if different indices are accessed. For these reasons, I was not able to actually incorporate parallelism into this project. It's my hope that with future updates to the Swift language, more robust parallelism can be performed to run higher performance algorithms on systems that can be easily distributed to clients.

## Clustering

### What is Clustering?

Clustering is a form of unsupervised machine learning in which a set of data is grouped into smaller subsets called clusters. One of the advantages of this type of learning over other forms of machine learning is that it does not require labeled data. This can be especially useful since more data than ever is being collected, but it takes a great deal of time and effort to manually clean and label data for digestion. While clustering has a limited range of use cases, it is often used in areas such as image segmentation and computer vision, to name a couple.

### The K-Means Clustering Algorithm

In laymen's terms, the K-Means algorithm performs the following four steps:

1. Pick some start points for the initial centers of each cluster
2. For each point in the data set, find the "closest" cluster
3. Update each centroid to be the average of all the points in the cluster
4. Repeat this process until the points no longer change, or until a maximum number of tierations is performed.

```pseudocode
// Pseudocode for naive K-Means
for i = 1 to K:
	centroid[i] = random() // some random starting point among the points in the dataset
for i = 1 to I: // for a max number of I iterations
	for j in 1 to N // iterate over n points
		min_dist = infinity
		for k in 1 to K:
			if dist(point[j],centroid[k]) < min_dist:
				min_dist = dist(point[j], centroid[k])
				clusters[j] = k
		nearest = clusters[j]
		group[nearest].insert(point[j])
	for i in 1 to K:
		centroid[i] = avg(group[j])
```

The preceding algorithm leads to a time complexity which is $O(KNMI)$ where $K$ is the number of clusters, $N$ is the number of points, $M$ is the number of dimmensions (features) in the data set, and I is a bound on the number of iterations.



### Testing the Algorithm

In order to test this algorithm, I opted to split testing up into two categories: accuracy and performance. The reason is quite simple. 

##### Accuracy

The most intuitive way to test the accuracy of the algorithm is to artificially create datapoints with specific clusters in mind. We choose $k$ different points in $n$ dimmensional space and add noise such that we generate a bunch of random points in roughly the same areas. Then, if the algorithm is implemented correctly, it should output a clustering that mirrors the one we artificially created.   This also requires fixing initial centroids such that each centroid is in it's own artificial cluster space, otherwise the clustering won't match. I crated a plethora of test cases with different variations of K, N and M, including some high-dimmensional 1000-Dimmensional data points.

##### Performance

While the above appraoch to generating test data is fantastic for testing the accuracy of the algorithm, it's quite unrealistic in terms of analyzing runtime. Most data sets will not fit into such neatly partitioned clusters and it obviously, running the algorithm on such neat clusters will result in less iterations until the centroids converge on each cluster. To rectify this, we create a set of completely random data within some range (ie -1000 to 1000) and attempt to cluster these sets. These data sets are organized in two main types, discrete points in $n$-Dimmensional space, and mock image sets in 6-Dimmensional space (r, g, b, a , x y). Benchmarks using these data sets did still produce a good deal of volatility, which is likely due to the non-deterministic way in which the start points are created.

### A Parallel Approach

When adding parallelism to this function, one has to be careful. First off, it must be noted that the outer-most loop must be run sequentially, since this algorithm depends on the centroids converging towards the center of their respecitve cluster of points. The next best choice then would be to parallelize the loop over each point. This is a great option except for one hang-up. In order to benefit from spatial locality and loop in a cache efficient, points in the data set are stored in linearly, so that a single point is contiguous in the array. This means the array might look something like $(x_1, y_1,z_1),(x_2, y_2, z_2), ...$ This makes calculating the distance quite efficient, but calculating the average of each componenent $(x, y, z)$ difficult. In order to still benefit from parallelism, we can solve this problem by storing an array containing only the cluster number for each point, and then use a parallel filtering algorithm in order to decompose the array into contiguous arrays of the corresponding components. So then our parallel algorithm will look something like the following.

```pseudocode
// Pseudocode for naive K-Means
for i = 1 to K:
	centroid[i] = random() // some random starting point among the points in the dataset
for i = 1 to I: // for a max number of I iterations
	parallel_for j in 1 to N // iterate over n points
		min_dist = infinity
		for k in 1 to K:
			if dist(point[j],centroid[k]) < min_dist:
				min_dist = dist(point[j], centroid[k])
				clusters[j] = k
	for k in 1 to K:
		group[k] = ParallelFilter(clusters, x == l) // Filter points in the current cluster
	for i in 1 to K:
		centroid[i] = avg(group[j])
```

Using this approach, our work is unchanged, but we have the potential benefit of utilizing parallelism divide that work by the number of cores. Thus $W = O(KNMI)$ and $S = \log(n)$.

As mentioned above, and in spite of the number of hours fighting for a solution, there simply is not a great way to implement this in Swift as of now.



### Cache Efficiency in Swift: Using Contiguous Arrays

Swift has a remarkable number of optimizations under the hood which make it perform much differently than expected compared to a standard implementation in C++. For example,  Structs in Swift are definitionally pass-by-value, only. Because of this, Swift is able to keep these structures light and very fast, but at the cost of being immutable. This may seem like a terrible idea if you consider the cost of passing a large array by value with some simple function. Swift corrects this by fundamentally changing the underlying copy mechanic. In essence, a copy of an array in Swift is a copy of a pointer to a memory address. No deep copy is performed until one of the values in the array changes. (This is known as Copy-On-Write). This uinderlying knowledge is really important in order to optimize our K-Means algorithm since during the lifetime of the algorithm, a significant amount of modifications to an existing array are performed over and over. One of the solutions we've implmented in order to fix this problem is declaring all of the large arrays used in the algorithm to be Contiguous Arrays, which perform much closer to their counterparts in Swift. By also leveraging spatial locality by accessing values in these arrays, we obtain a decent speed-up from the naive approach.



**Test 1**: 10,000 Points, 3 Dimmensions, 10 Clusters

**Test 2**: 20,00 Points, 5 Dimmensions, 10 Clusters

**Test 3**: 100,000 Points, 2 Dimmensions, 8 Clusters

**Test 4**: 250x250 Image (62,500 Pixels), 6 Dimmensions, 8 Clusters

**Test 5**: 640x480 Image (307,200 Pixels), 6 Dimmensions, 2 Clusters



**Before Utilizing Contiguous Arrays**

Test 1 | Time elapsed: 0.9877209663391113 seconds

Test 2 | Time elapsed: 2.8197929859161377 seconds

Test 3 | Time elapsed: 6.185441970825195 seconds

Test 4 | Time elapsed: 8.352222084999084 seconds

Test 5 | Time elapsed: 12.850023984909058 seconds



**After Utilizing Contiguous Arrays**

Switch to using contiguous array

Test 1 | Time elapsed: 0.893867015838623 seconds

Test 2 | Time elapsed: 2.5795741081237793 seconds

Test 3 | Time elapsed: 5.705821990966797 seconds

Test 4 | Time elapsed: 7.646713972091675 seconds

Test 5 | Time elapsed: 11.85356593132019 seconds



### Choosing Better Start Points

While it is convenient to treat this algorithm as having a max number of iteration $I$, it is not very practical. In most cases, K-Means clustering is implemented such that the algorithm stops when the centroids no longer move or the data points no longer change clusters between iterations. There are some very significant advantages and disadvantages to this. In the case that good start points are chosen, the algorithm will converge much more quickly than if a set number of iterations was reached. Yet this can also have the opposite effect in case bad starting points are picked. The naive implementation of the algorithm involves choosuing points completely randomly and assigning a centroid to that random point. A better approach is to use a method known as Scrambled Midpoints<sup>[2](https://tigerprints.clemson.edu/cgi/viewcontent.cgi?article=1023&context=computing_pubs)</sup>.

The below snippet details this approach:

```swift
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

```

The results from implementing this were mixed. These tests were performed after adjusting the cluster condition to repeat until convergence, not a fixed range of iterations. This, of course, caused the same performance tests to yield a slower runtime, since likely, many of the test cases finished iterating before the centroids converged to a single value. Because the accuracy tests were derived from artificial clusterings, they converge very quickly such that the constant iteration bound did not impede the accuracy. Nonetheless, below are the results before and after implementing scrambled midpoints.

**Random Initial Centroids**

Test 1 Average: 1.7736753940582275 seconds

Test 2 Average: 12.113093376159668 seconds

Test 3 Average: 24.064936995506287 seconds

Test 4 Average: 85.06900000572205 seconds

Test 5 Average: 19.10009765625 seconds



**Using Scrambled Midpoints**

Test 1 Average: 1.7117783784866334 seconds

Test 2 Average: 19.594633412361144 seconds

Test 3 Average: 21.562797594070435 seconds

Test 4 Average: 88.88137619495392 seconds

Test 5 Average: 17.033718204498292 seconds



As you can see, most of the tests ended up taking slightly longer than with completely random initial centroids. Still, there were a few cases in which there was an improbement. The two cases in which there was improvement was with the largest image, and the smallest set of discrete points, which doesn't lead to any obvious pattern. Still, the conclusion must be that  in some cases, the better selection of midpoints leads to a quicker convergence, while in other cases, the extra time to calculate midpoints does not lead to a better runtime than to completely randomize the selection. Perhaps on a larger scale of tests, my findings would mirror those from the team at Clemson who came up with the optimization.



### Using Arithmetic to Optimize The Distance Calculation

There's one last very simple optimziation that we can make is to optimize the distance calculation. The standard formula for euclidean distance between two points $x$ and $y$ is $d(x,y) = \sqrt{(x_1-y_1)^2 + ... + (x_n - y_n)^2}$. However, because we only need to compare distances between pairs of points, and since this is a monotonic function, we can remove the square root without affecting the accuracy of the algorithm. Thus, the distance will actually return the distance squared rather than the strict euclidean distance. After these improvements, the following were my results:

Test 1 Average: 2.088760995864868 seconds

Test 2 Average: 11.210158777236938 seconds

Test 3 Average: 22.262320041656494 seconds

Test 4 Average: 74.03789739608764 seconds

Test 5 Average: 13.775614833831787 seconds



### Conclusions

The goal of this project was to implement an optimized K-Means Clustering algorithm with parallelism using Swift / SwiftUI. Unfortunately, this just wasn't quite feasible with the current technolog. I spent dozens of hours researching optimizations in Swift such as the underlying architecture, cache efficiency, concurrency and parallelism. It was quite a duanting task and in hindsight, I probably bit off more than I could chew. If I could do this project over again, I would start from scratch in C++ just so that I could have more flexibility to fine-tune without the compiler making more of those decisions for me. In the end though, I was able to make implement the algorithm correctly, in such a way that it can take any size input, and I was able to do so while leveraging cache-efficiency and making some arithmetical optimzations too. In this sense, I think that this project was a success and it's one I'd love to come back to at some point in the future.



### References

1. https://cseweb.ucsd.edu/~avattani/papers/kmeans_hardness.pdf

2. https://tigerprints.clemson.edu/cgi/viewcontent.cgi?article=1023&context=computing_pubs
