//
//  LidarMesh.swift
//  lidar
//
//  Created by Anastasia Rudenko on 29.03.2021.
//

import ARKit
import SwiftUI

struct LidarMesh: UIViewRepresentable {
    @Binding var scnMaterialParameters: SCNMaterialParameters
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = context.coordinator
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .mesh
        sceneView.session.run(config)
        return sceneView
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        let parent : LidarMesh
        init(_ parent: LidarMesh) {
            self.parent = parent
        }
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
            node.geometry = SCNGeometry.makeFromMeshAnchor(meshAnchor,
                                                           customInitScnMaterialParameters(scnMaterialParameters: parent.scnMaterialParameters))
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
}

