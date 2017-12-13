//
//  ViewController+ARSCNDelegate.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/10/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.grabbedObject?.updateGrabbedPosition(relativeTo: self.sceneView.pointOfView!)
    }
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}
