//
//  ARTableView.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/14/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//
//  This is a simple implementation for an AR TableView.
//
//  Currently only able to hold a collection of ARTableViewCells and
//  automatically lays them out. Will add scrolling and paging soon.
//
//  I tried to keep the usage patterns similar to UITableViews, with a
//  data-source protocol to be implemented by the ViewController containing
//  the ARTableView.

import UIKit
import SceneKit
import ARKit

protocol ARTableViewDataSource : NSObjectProtocol {
    func numberOfCells(in tableView: ARTableView) -> Int
    func arTableView(_ tableView: ARTableView, cellAtIndex index : Int) -> ARTableViewCell
}

class ARTableView: SCNNode {
    
    var dataSource : ARTableViewDataSource?
    
    var tableSurfaceNode : SCNNode!
    var tableSurfaceTexture : Any?
    
    var cells = [ARTableViewCell]()
    
    let cellWidth : CGFloat = 0.3
    
    init(dataSource: ARTableViewDataSource, surfaceTexture: Any? = nil) {
        super.init()
        self.name = "ARTableView"
        self.dataSource = dataSource
        self.tableSurfaceTexture = surfaceTexture ?? UIColor.white
        
        reload()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Reloads the entire ARTableView. Grabbing fresh data from the data-source
    /// and laying it out again.
    func reload() {
        guard let dataSource = dataSource else { return }
        
        for child in self.childNodes {
            child.removeFromParentNode()
        }
        
        let totalCells = dataSource.numberOfCells(in: self)
        let tableWidth = cellWidth * CGFloat(totalCells)
        
        let sides = SCNMaterial()
        sides.diffuse.contents = UIColor.black
        let surfaces = SCNMaterial()
        surfaces.diffuse.contents = tableSurfaceTexture
        
        let tableSurface = SCNBox(width: tableWidth, height: 0.025, length: 0.3, chamferRadius: 0.01)
        tableSurface.materials = [sides, sides, sides, sides, surfaces, surfaces]
        
        tableSurfaceNode = SCNNode(geometry: tableSurface)
        tableSurfaceNode.simdPosition = simd_float3(0, -0.2, 0)
        addChildNode(tableSurfaceNode)
        
        for i in 0 ..< totalCells {
            let cell = dataSource.arTableView(self, cellAtIndex: i)
            let x = CGFloat(i) * cellWidth + (cellWidth / 2) - (tableWidth / 2)
            cell.position = SCNVector3(x, 0, 0)
            
            cells.append(cell)
            addChildNode(cell)
        }
    }
}

class ARTableViewCell : SCNNode {
    
    var content : SCNNode!
    var button : ARButton!
    
    init(content: SCNNode, buttonImageName: String) {
        super.init()
        
        self.content = content
        addChildNode(content)
        
        button = ARButton(named: "ARTableViewButton", withImageNamed: buttonImageName)
        button.simdPosition = simd_float3(0, -0.2, 0.25)
        button.simdEulerAngles = simd_float3(-45, 0, 0)
        addChildNode(button)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
