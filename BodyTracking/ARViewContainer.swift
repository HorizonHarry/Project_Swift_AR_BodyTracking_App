//
//  ARViewContainer.swift
//  BodyTracking
//
//  Created by Harry Horizon on 9/12/2567 BE.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var appState = AppState.shared
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        // 1. Support Check
        guard ARBodyTrackingConfiguration.isSupported else {
            appState.statusMessage = "Device not supported"
            return arView
        }
        
        arView.setupForBodyTracking()
        arView.scene.addAnchor(context.coordinator.bodySkeletonAnchor)
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.bodySkeletonAnchor.isEnabled = appState.showSkeleton
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var bodySkeleton: BodySkeleton?
        let bodySkeletonAnchor = AnchorEntity()
        var lastUpdate: Date = Date()
        var timer: Timer?

        override init() {
            super.init()
            // Poll to check if tracking is still fresh
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                if AppState.shared.isTracking && Date().timeIntervalSince(self?.lastUpdate ?? Date()) > 1.0 {
                    DispatchQueue.main.async {
                        AppState.shared.isTracking = false
                        AppState.shared.statusMessage = "Subject Lost"
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            let bodyAnchors = anchors.compactMap { $0 as? ARBodyAnchor }
            
            if let bodyAnchor = bodyAnchors.first {
                lastUpdate = Date()
                if !AppState.shared.isTracking {
                    DispatchQueue.main.async {
                        AppState.shared.isTracking = true
                        AppState.shared.statusMessage = "Tracking Active"
                    }
                }
                
                if let skeleton = bodySkeleton {
                    skeleton.update(with: bodyAnchor)
                } else {
                    let newSkeleton = BodySkeleton(for: bodyAnchor)
                    bodySkeleton = newSkeleton
                    bodySkeletonAnchor.addChild(newSkeleton)
                }
            }
        }
        
        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            for anchor in anchors {
                if anchor is ARBodyAnchor {
                    DispatchQueue.main.async {
                        AppState.shared.isTracking = false
                        AppState.shared.statusMessage = "Searching..."
                    }
                }
            }
        }
    }
}

extension ARView {
    func setupForBodyTracking() {
        let configuration = ARBodyTrackingConfiguration()
        self.session.run(configuration)
    }
}

