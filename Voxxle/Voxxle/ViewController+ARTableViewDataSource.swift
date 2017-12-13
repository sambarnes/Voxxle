//
//  ViewController+ARTableViewDataSource.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/14/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension ViewController: ARTableViewDataSource {

    func numberOfCells(in tableView: ARTableView) -> Int {
        return Voxxle.instance.numberOfLevels
    }
    
    func arTableView(_ tableView: ARTableView, cellAtIndex index: Int) -> ARTableViewCell {
        // For unlocked/available levels, return a cell containing a level preview and a start button
        if Voxxle.instance.islevelUnlocked(atIndex: index) {
            let board = Voxxle.instance.gameBoard(forLevelAtIndex: index)
            let boardNode = SCNNode()
            boardNode.scale = SCNVector3(0.05, 0.05, 0.05)
            let solved = Voxxle.instance.hasLevelBeenSolved(atIndex: index)
            let texture = solved ? UIImage(named: Art.green) : UIImage(named: Art.white)
            for point in board {
                let voxel = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                voxel.firstMaterial?.diffuse.contents = texture
                let voxelNode = SCNNode(geometry: voxel)
                voxelNode.simdPosition = point
                boardNode.addChildNode(voxelNode)
            }
            
            let cell = ARTableViewCell(content: boardNode, buttonImageName: "start")
            cell.button.buttonAction = { ()->Void in
                self.showGameNode(forLevel: index)
            }
            return cell
        }
        
        // For locked levels, return a generic gray cube and a locked button
        let board = Voxxle.instance.gameBoard(forLevelAtIndex: 0)
        let boardNode = SCNNode()
        boardNode.scale = SCNVector3(0.05, 0.05, 0.05)
        let texture = UIImage(named: Art.gray)
        for point in board {
            let voxel = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
            voxel.firstMaterial?.diffuse.contents = texture
            let voxelNode = SCNNode(geometry: voxel)
            voxelNode.simdPosition = point
            boardNode.addChildNode(voxelNode)
        }
        let cell = ARTableViewCell(content: boardNode, buttonImageName: "locked")
        cell.button.buttonAction = { ()->Void in
            print("Locked Level Selected")
        }
        return cell
    }
}
