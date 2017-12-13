//
//  ARSCNView+HitTesting.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/11/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ARSCNView {
    
    /// Bitmasks for allowing/ignoring hit-tests
    enum HitTestType : Int {
        case allow = 0b0001
        case ignore = 0b0010
    }
    
    /// Hit tests against the `sceneView` to find an object at the provided point.
    func virtualObject(at point: CGPoint) -> SCNNode? {
        let bitMask = HitTestType.allow.rawValue
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true, .categoryBitMask : bitMask]
        let hitTestResults = hitTest(point, options: hitTestOptions)
        
        return hitTestResults.lazy.flatMap { result in
            return result.node
        }.first
    }
    
    /// Hit tests against the `sceneView` to find an Interactable Object at the provided point.
    func interactableObject(at point: CGPoint) -> ARInteractableObject? {
        let bitMask = HitTestType.allow.rawValue
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true, .categoryBitMask : bitMask]
        let hitTestResults = hitTest(point, options: hitTestOptions)
        
        return hitTestResults.lazy.flatMap { result in
            return ARInteractableObject.existingObjectContainingNode(result.node)
            }.first
    }
    
}
