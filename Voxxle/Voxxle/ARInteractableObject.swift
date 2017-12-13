//
//  ARInteractableObject.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/15/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//
//  Currently only supports basic object grabbing and moving,
//  but I will be working on more simplified ways to manipulate
//  the given object.

import SceneKit
import ARKit

/// An object that can be picked up, manipulated, and put down in AR
class ARInteractableObject: SCNNode {
    
    var content : SCNNode!
    var isGrabbed = false
    
    var originalParent : SCNNode?
    var grabbedParent : SCNNode?
    
    init(named name: String, withContent content: SCNNode) {
        super.init()
        self.name = name
        self.content = content
        addChildNode(content)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func grab(byCamera camera: SCNNode, inView sceneView: ARSCNView) {
        isGrabbed = true
        
        let newTransform = simdWorldTransform
        originalParent = self.parent
        self.removeFromParentNode()
        
        grabbedParent = SCNNode()
        grabbedParent?.addChildNode(self)
        sceneView.scene.rootNode.addChildNode(grabbedParent!)
        grabbedParent?.simdWorldTransform = camera.simdWorldTransform
        self.simdWorldTransform = newTransform
    }
    
    func ungrab() {
        isGrabbed = false
        
        let newTransform = simdWorldTransform
        self.removeFromParentNode()
        originalParent!.addChildNode(self)
        self.simdWorldTransform = newTransform
        
        grabbedParent?.removeFromParentNode()
        grabbedParent = nil
    }
    
    func updateGrabbedPosition(relativeTo grabber: SCNNode) {
        guard self.isGrabbed else { return }
        grabbedParent!.simdPosition = grabber.simdPosition
        grabbedParent!.simdRotation = grabber.simdRotation
        let pointToFace = originalParent!.simdConvertPosition(simd_float3(0, 0, -100), to: grabbedParent!.parent)
        self.simdLook(at: pointToFace)
    }
    
}

extension ARInteractableObject {
    
    /// Returns an ARInteractableObject if one exists as an ancestor to the provided node.
    static func existingObjectContainingNode(_ node: SCNNode) -> ARInteractableObject? {
        if let virtualObjectRoot = node as? ARInteractableObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is an ARInteractableObject.
        return existingObjectContainingNode(parent)
    }
    
}
