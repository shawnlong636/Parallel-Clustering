//
//  ContentView.swift
//  Shared
//
//  Created by Shawn Long on 3/5/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    var body: some View {
        VStack(alignment: .leading) {
            Text("K Way Means")
                .font(.title).bold()
            Image("SampleBrain")
                .resizable()
                .scaledToFit()
//            LogView()
            HStack(alignment: .center) {
                Text("Segment the Image: ")
                Button("Button") {
                    modelData.logs.append("Adding line of text")
                    }
                }
            }

            .frame(minWidth: 300)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject({() -> ModelData in
            let modelData = ModelData()
            modelData.logs = ["Sample Text 1", "Sample Text 2"]
            return modelData
        }() )

    }
}
