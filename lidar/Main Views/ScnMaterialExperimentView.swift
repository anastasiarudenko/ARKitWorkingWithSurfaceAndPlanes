//
//  ContentView.swift
//  lidar
//
//  Created by Anastasia Rudenko on 29.03.2021.
//

import SwiftUI
import ARKit

struct ScnMaterialExperiment: View {
    @State private var showingChangeScnMaterialParameters = false
    @State var scnMaterialParameters = SCNMaterialParameters()
    var body: some View {
        ZStack {
            LidarMesh(scnMaterialParameters: $scnMaterialParameters)
                .ignoresSafeArea().statusBar(hidden: true).disabled(true)
                
            VStack {
                if showingChangeScnMaterialParameters {
                    ModifySCNMaterialParameters(scnMaterialParameters: $scnMaterialParameters)
                }
                Spacer()
                Button("Change") {
                    showingChangeScnMaterialParameters.toggle()
                }.frame(height: 100)
            }
        }
    }
}
