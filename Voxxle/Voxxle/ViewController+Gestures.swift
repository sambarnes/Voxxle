//
//  ViewController+Gestures.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/11/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ViewController : UIGestureRecognizerDelegate {
    
    /// Create and add gestures to the ARSCNView
    func setupGestures() {
        // Object Rotation Gestures
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.trySwipeRotation(_:)))
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.trySwipeRotation(_:)))
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.trySwipeRotation(_:)))
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.trySwipeRotation(_:)))
        swipeUpGesture.direction = .up
        swipeDownGesture.direction = .down
        swipeLeftGesture.direction = .left
        swipeRightGesture.direction = .right
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tryDoubleTapRotation(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        
        // Object Translation Gesture
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.tryMovingObject(_:)))
        longPressGesture.minimumPressDuration = 0.1
        
        // Button Listener Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tryTappingButton(_:)))
        tapGesture.delegate = self
        tapGesture.require(toFail: doubleTapGesture)
        
        sceneView.addGestureRecognizer(swipeUpGesture)
        sceneView.addGestureRecognizer(swipeDownGesture)
        sceneView.addGestureRecognizer(swipeLeftGesture)
        sceneView.addGestureRecognizer(swipeRightGesture)
        sceneView.addGestureRecognizer(doubleTapGesture)
        sceneView.addGestureRecognizer(longPressGesture)
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    /// UISwipeGesture fired. Used for rotating an object using up/down/left/right swipes
    @objc func trySwipeRotation(_ gesture : UISwipeGestureRecognizer) {
        // Hit-test to determine if user is swiping on an ARInteractableObject
        let touchLocation = gesture.location(in: sceneView)
        guard let interactableObject = sceneView.interactableObject(at: touchLocation) else { return }
        
        var rotateAction : SCNAction?
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.up:
            // determine which axis is closest to perpendicular to the camera's front vector
            var pointInFront = self.sceneView.pointOfView!.simdConvertPosition(simd_float3(0, 0, -100), to: interactableObject)
            
            if abs(pointInFront.x) > abs(pointInFront.z) {
                let sign = pointInFront.x > 0 ? 1 : -1
                rotateAction = SCNAction.rotate(by: -CGFloat.pi / 2, around: SCNVector3(0, 0, sign), duration: 0.25)
            } else {
                let sign = pointInFront.z > 0 ? 1 : -1
                rotateAction = SCNAction.rotate(by: CGFloat.pi / 2, around: SCNVector3(sign, 0, 0), duration: 0.25)
            }
            break
        case UISwipeGestureRecognizerDirection.down:
            // determine which axis is closest to perpendicular to the camera's front vector
            var pointInFront = self.sceneView.pointOfView!.simdConvertPosition(simd_float3(0, 0, -100), to: interactableObject)
            if abs(pointInFront.x) > abs(pointInFront.z) {
                let sign = pointInFront.x > 0 ? 1 : -1
                rotateAction = SCNAction.rotate(by: CGFloat.pi / 2, around: SCNVector3(0, 0, sign), duration: 0.25)
            } else {
                let sign = pointInFront.z > 0 ? 1 : -1
                rotateAction = SCNAction.rotate(by: -CGFloat.pi / 2, around: SCNVector3(sign, 0, 0), duration: 0.25)
            }
            break
        case UISwipeGestureRecognizerDirection.left:
            rotateAction = SCNAction.rotate(by: -CGFloat.pi / 2, around: SCNVector3(0, 1, 0), duration: 0.25)
            break
        case UISwipeGestureRecognizerDirection.right:
            rotateAction = SCNAction.rotate(by: CGFloat.pi / 2, around: SCNVector3(0, 1, 0), duration: 0.25)
            break
        default:
            break
        }
        guard let action = rotateAction else { return }
        interactableObject.content.runAction(action, completionHandler: {
            self.checkPiecePositions()
        })
    }
    
    /// UITapGesture fired. Used for rotating an object in the direction that swipes cannot
    @objc func tryDoubleTapRotation(_ gesture : UITapGestureRecognizer) {
        // Hit-test to determine if user double tapped on an ARInteractableObject
        let touchLocation = gesture.location(in: sceneView)
        guard let interactableObject = sceneView.interactableObject(at: touchLocation) else { return }
        
        // determine which axis is closest to parallel to the camera's front vector
        var pointInFront = self.sceneView.pointOfView!.simdConvertPosition(simd_float3(0, 0, -100), to: interactableObject)
        var rotationAxis : SCNVector3
        if abs(pointInFront.x) > abs(pointInFront.z) {
            let sign = pointInFront.x > 0 ? 1 : -1
            rotationAxis = SCNVector3(sign, 0, 0)
        } else {
            let sign = pointInFront.z > 0 ? 1 : -1
            rotationAxis = SCNVector3(0, 0, sign)
        }
        // rotate around that axis
        let rotateAction = SCNAction.rotate(by: CGFloat.pi / 2, around: rotationAxis, duration: 0.25)
        interactableObject.content.runAction(rotateAction, completionHandler: {
            self.checkPiecePositions()
        })
    }
    
    /// UILongPressGesture fired. Used for moving virtual objects
    @objc func tryMovingObject(_ gesture : UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Hit-test to determine if user long-pressed on an ARInteractableObject
            // and if so, grab it
            let touchLocation = gesture.location(in: sceneView)
            let tappedObject = sceneView.interactableObject(at: touchLocation)
            if let interactableObject = tappedObject {
                interactableObject.grab(byCamera: sceneView.pointOfView!, inView: sceneView)
                grabbedObject = interactableObject
            }
            break
        case.ended:
            // Ungrab the currently grabbed object if it exists
            if let interactableObject = grabbedObject {
                interactableObject.ungrab()
                grabbedObject = nil
                
                // Snap piece to board
                let raw = interactableObject.position
                let adjustedPosition = SCNVector3(roundf(raw.x), roundf(raw.y), roundf(raw.z))
                let translateAction = SCNAction.move(to: adjustedPosition, duration: 0.25)
                interactableObject.runAction(translateAction, completionHandler: {
                    self.checkPiecePositions()
                })
            }
            break
        default:
            break
        }
    }
    
    /// UITapGesture fired. Used for button presses
    @objc func tryTappingButton(_ gesture : UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: sceneView)
        let tappedObject = sceneView.virtualObject(at: touchLocation)
        if let button = tappedObject as? ARButton {
            button.pressed()
        }
    }
    
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func checkPiecePositions() {
        var allOnBoard = true
        for child in currentGameBoardNode!.childNodes {
            guard let piece = child as? ARInteractableObject else { continue }
            
            // Check if the piece is on the board, gray it out if not
            let isOnBoard = self.isPieceValidOnBoard(piece)
            let texture = isOnBoard ? UIImage(named: piece.name!) : UIImage(named: Art.gray)
            for voxelNode in piece.content.childNodes {
                voxelNode.geometry?.firstMaterial?.diffuse.contents = texture
            }
            allOnBoard = allOnBoard && isOnBoard
        }
        if allOnBoard {
            checkForWin()
        }
    }
    
    /// Returns true if any point in the piece overlaps a part of the board
    func isPieceOnBoard(_ piece: ARInteractableObject) -> Bool {
        for voxelNode in piece.content.childNodes {
            var pointInBoardSpace = piece.content.simdConvertPosition(voxelNode.simdPosition, to: currentGameBoardNode!)
            pointInBoardSpace = simd_float3(round(pointInBoardSpace.x), round(pointInBoardSpace.y), round(pointInBoardSpace.z))
            for child in currentGameBoardNode!.childNodes {
                if child is ARInteractableObject {
                    continue
                }
                if child.simdPosition == pointInBoardSpace {
                    return true
                }
            }
        }
        return false
    }
    
    /// Returns true if every point in the piece is on the board
    func isPieceValidOnBoard(_ piece: ARInteractableObject) -> Bool {
        for voxelNode in piece.content.childNodes {
            var pointInBoardSpace = piece.content.simdConvertPosition(voxelNode.simdPosition, to: currentGameBoardNode!)
            pointInBoardSpace = simd_float3(round(pointInBoardSpace.x), round(pointInBoardSpace.y), round(pointInBoardSpace.z))
            var found = false
            for child in currentGameBoardNode!.childNodes {
                if child is ARInteractableObject { continue }
                if child.simdPosition == pointInBoardSpace {
                    found = true
                    break
                }
            }
            if !found {
                return false
            }
        }
        return true
    }
    
    func checkForWin() {
        // Check to see if every point on the board is covered
        var allPointsCovered = true
        let boardChildren = currentGameBoardNode!.childNodes
        for child in boardChildren {
            if child is ARInteractableObject { continue }
            let position = child.simdPosition
            
            var pointCovered = false
            for otherChild in boardChildren {
                guard let piece = otherChild as? ARInteractableObject else { continue }
                for voxelNode in piece.content.childNodes {
                    var pointInBoardSpace = piece.content.simdConvertPosition(voxelNode.simdPosition, to: currentGameBoardNode!)
                    pointInBoardSpace = simd_float3(round(pointInBoardSpace.x), round(pointInBoardSpace.y), round(pointInBoardSpace.z))
                    if position == pointInBoardSpace {
                        pointCovered = true
                        break
                    }
                }
                if pointCovered { break }
            }
            allPointsCovered = allPointsCovered && pointCovered
        }
        
        if !allPointsCovered { return }
        
        // WINNER!
        Voxxle.instance.markLevelSolved(atIndex: currentLevel!)
        
        let returnToMenuAction = UIAlertAction(title: NSLocalizedString("Return to Level Selection", comment: "Default action"), style: .cancel, handler: { _ in
            self.showLevelSelection()
        })
        let title = "Congrats! You've won!"
        let message = "Everyone said you couldn't do it.\nAnd to think I almost believed them..."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(returnToMenuAction)
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}
