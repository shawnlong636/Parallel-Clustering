//
//  Parallel_ClusteringApp.swift
//  Shared
//
//  Created by Shawn Long on 3/5/22.
//

import SwiftUI

@main
struct Parallel_ClusteringApp: App {
    @StateObject var modelData = ModelData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
    }
}
