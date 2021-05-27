//
//  EmotionTracking.swift
//  lidar
//
//  Created by Anastasia Rudenko on 05.04.2021.
//

import ARKit
import SwiftUI

struct EmotionTracking: UIViewRepresentable {
    private let sceneView = ARSCNView(frame: UIScreen.main.bounds)
    private var textNode: SCNNode?
    private let model = try! VNCoreMLModel(for: CNNEmotions().model)
    
    func makeUIView(context: Context) -> ARSCNView {
        sceneView.delegate = context.coordinator
        sceneView.showsStatistics = true
        sceneView.session.run(ARFaceTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
//        sceneView.autoenablesDefaultLighting = true
//        sceneView.delegate = context.coordinator
//        let config = ARWorldTrackingConfiguration()
//        config.environmentTexturing = .automatic
//        config.sceneReconstruction = .mesh
//        sceneView.session.run(config)
        return sceneView
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent : EmotionTracking
        init(_ parent: EmotionTracking) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let device = parent.sceneView.device else { return nil }
            let node = SCNNode(geometry: ARSCNFaceGeometry(device: device))
            node.geometry?.firstMaterial?.fillMode = .lines
            return node
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let faceGeometry = node.geometry as? ARSCNFaceGeometry, parent.textNode == nil else { return }
            parent.addTextNode(faceGeometry: faceGeometry)
        }

        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor,
                let faceGeometry = node.geometry as? ARSCNFaceGeometry,
                let pixelBuffer = parent.sceneView.session.currentFrame?.capturedImage
                else {
                return
            }
            
            faceGeometry.update(from: faceAnchor.geometry)

            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:]).perform([VNCoreMLRequest(model: parent.model) { [weak self] request, error in
                    guard let firstResult = (request.results as? [VNClassificationObservation])?.first else { return }
                    DispatchQueue.main.async {
                        if firstResult.confidence > 0.92 {
                            (self?.parent.textNode?.geometry as? SCNText)?.string = firstResult.identifier
                        }
                    }
                }])
        }
//        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
//            node.geometry = SCNGeometry.makeFromMeshAnchor(meshAnchor,
//                                                           customInitScnMaterialParameters(scnMaterialParameters: parent.scnMaterialParameters))
//        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
    
    private mutating func addTextNode(faceGeometry: ARSCNFaceGeometry) {
        let text = SCNText(string: "", extrusionDepth: 1)
        text.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemIndigo
        text.materials = [material]

        let textNode = SCNNode(geometry: faceGeometry)
        textNode.position = SCNVector3(-0.3, 0.3, -0.5)
        textNode.scale = SCNVector3(0.003, 0.003, 0.003)
        textNode.geometry = text
        self.textNode = textNode
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}

