//
//  LogView.swift
//  Parallel Clustering
//
//  Created by Shawn Long on 3/5/22.
//

import SwiftUI

struct LogView: View {
    @EnvironmentObject var modelData: ModelData

    var body: some View {
        ScrollView(){
            VStack(alignment: .leading) {
                ForEach(modelData.logs, id: \.self) { text in
                    Text(text)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding()

        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
            .padding()
            .environmentObject({() -> ModelData in
            let modelData = ModelData()
            modelData.logs = ["Sample Text 1", "Sample Text 2"]
            return modelData
        }() )
    }
}
