//
//  ViewController.swift
//  Voxxle
//
//  Created by Sam Barnes on 10/28/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//
//  Notes:
//  This file is the main controller for the application.
//
//  It contains the following:
//  - lifecycle events for the View
//  - ARSCNView setup and scene creation
//  - scene control functions
//  - game-state transitions
//  - gesture recognizers
//  - implementation of ARTableViewDataSource functions
//
//  For sake of readability and organization, I split up the
//  view controller into multiple extension files. For example, all
//  gesture related code is contained within ViewController+Gestures.swift
//
//  As far as SceneKit code goes, I decided to keep everything in a single
//  SCNScene due to the fact that the various application stages are relatively
//  simple. Transitions between stages are done by replacing the currentNode
//  variable with whatever stage the user is attempting to transition to.

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var mainMenuButton: UIButton!
    
    @IBOutlet weak var helpButton: UIButton!
    
    /// The node that is currently presented to the user. Will be either:
    /// mainMenuNode, levelSelectNode, or a gameNode
    var currentNode : SCNNode?
    
    /// The current node holding the gameboard
    var currentGameBoardNode : SCNNode?
    
    /// The current level number
    var currentLevel : Int?
    
    /// The currently grabbed object in the scene. Nil when no object is grabbed
    var grabbedObject : ARInteractableObject?
    
    // MARK: Lifecycle Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
        setupGestures()
        showMainMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration & run it
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // TODO: Evaluate if keeping the entire game state is heavy on memory
    }

    /// Re-positions the currentNode 1 meter in front of the user's current
    /// world-space position and orientation
    @IBAction func recenterScene(_ sender: UIButton) {
        // apply a translation to the currently active node
        let camera = sceneView.session.currentFrame!.camera
        var translation = camera.transform
        translation.columns.3.z = -1
        currentNode?.simdTransform = matrix_multiply(camera.transform, translation)
        // correct the rotation
        currentNode?.eulerAngles = SCNVector3(0,camera.eulerAngles.y, 0)
    }
    
    /// Returns an SCNNode with SCNText geometry for the given string, at a size
    /// that is appropriate for the scene, with a black outline and white faces
    func createTextNode(withText text: String) -> SCNNode {
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        
        let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
        textGeometry.chamferRadius = 0.02
        textGeometry.font = textGeometry.font.withSize(1)
        textGeometry.materials = [whiteMaterial, whiteMaterial, blackMaterial, blackMaterial, blackMaterial]
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.1, 0.1, 0.1)
        return textNode
    }
    
    // MARK: Main Menu
    
    lazy var mainMenuNode : SCNNode = {
        // Title
        let titleNode = createTextNode(withText: "Voxxle")
        titleNode.position = SCNVector3(-0.15, 0,0)
        
        // Logo
        let board = Voxxle.instance.gameBoard(forLevelAtIndex: 0)
        let logoNode = SCNNode()
        logoNode.position = SCNVector3(0, -0.1, 0)
        logoNode.scale = SCNVector3(0.1, 0.1, 0.1)
        for point in board {
            let voxel = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
            voxel.firstMaterial?.diffuse.contents = UIImage(named: Art.instance.randomCubeTexture())
            let voxelNode = SCNNode(geometry: voxel)
            voxelNode.simdPosition = point
            logoNode.addChildNode(voxelNode)
        }
        
        // Menu Options
        let playButton = ARButton(named: "Play", withImageNamed: "gamepad")
        playButton.buttonAction = { () -> Void in
            self.showLevelSelection()
        }
        let leaderboardsButton = ARButton(named: "Leaderboards", withImageNamed: "leaderboards")
        leaderboardsButton.simdPosition = playButton.simdPosition + simd_float3(-0.2, 0, 0)
        let settingsButton = ARButton(named: "Settings", withImageNamed: "settings")
        settingsButton.simdPosition = playButton.simdPosition + simd_float3(0.2, 0, 0)
        
        let optionsNode = SCNNode()
        optionsNode.simdPosition = logoNode.simdPosition + simd_float3(0, -0.25, 0.25)
        optionsNode.addChildNode(playButton)
        optionsNode.addChildNode(leaderboardsButton)
        optionsNode.addChildNode(settingsButton)
        
        let node = SCNNode()
        node.position = SCNVector3(0, 0, -1)
        node.addChildNode(titleNode)
        node.addChildNode(logoNode)
        node.addChildNode(optionsNode)
        return node
    }()
    
    @IBAction func showMainMenu() {
        mainMenuButton.isHidden = true
        helpButton.isHidden = true
        if let currentNode = currentNode {
            mainMenuNode.transform = currentNode.transform
            sceneView.scene.rootNode.replaceChildNode(currentNode, with: mainMenuNode)
        } else {
            sceneView.scene.rootNode.addChildNode(mainMenuNode)
        }
        currentNode = mainMenuNode
    }
    
    @IBAction func showHelpMessage(_ sender: UIButton) {
        let returnToMenuAction = UIAlertAction(title: NSLocalizedString("Got it!", comment: "Default action"), style: .cancel, handler: { _ in
            // do nothing
        })
        let title = "How to Play:"
        let message =   "- Tap & hold on a piece to pick it up\n" +
                        "- Move it by moving your device around\n" +
                        "- Swipe on a piece to rotate naturally\n" +
                        "- Double tap on a piece to rotate around the last possible axis\n" +
                        "- Fit all of the pieces onto the board positions to win the level"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(returnToMenuAction)
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Level Selection
    
    lazy var levelSelectNode : SCNNode = {
        // Title
        let titleNode = createTextNode(withText: "Select Level")
        titleNode.position = SCNVector3(-0.3, 0,0)
        
        let tableView = ARTableView(dataSource: self, surfaceTexture: UIImage(named: "wood_texture"))
        
        let node = SCNNode()
        node.position = SCNVector3(0, 0, -1)
        node.addChildNode(titleNode)
        node.addChildNode(tableView)
        return node
    }()
    
    func showLevelSelection() {
        mainMenuButton.isHidden = false
        helpButton.isHidden = true
        if let currentNode = currentNode {
            levelSelectNode.transform = currentNode.transform
            sceneView.scene.rootNode.replaceChildNode(currentNode, with: levelSelectNode)
        }
        if let tableView = levelSelectNode.childNode(withName: "ARTableView", recursively: false) as? ARTableView {
            tableView.reload()
        }
        currentNode = levelSelectNode
    }
    
    // MARK: In-Game
    
    func gameNode(forLevel index: Int) -> SCNNode {
        let board = Voxxle.instance.gameBoard(forLevelAtIndex: index)
        let boardNode = SCNNode()
        boardNode.scale = SCNVector3(0.1, 0.1, 0.1)
        let whiteTexture = UIImage(named: Art.white)
        for point in board {
            let voxel = SCNBox(width: 0.75, height: 0.75, length: 0.75, chamferRadius: 0)
            voxel.firstMaterial?.diffuse.contents = whiteTexture
            voxel.firstMaterial?.blendMode = .multiply
            let voxelNode = SCNNode(geometry: voxel)
            voxelNode.simdPosition = point
            voxelNode.categoryBitMask = ARSCNView.HitTestType.ignore.rawValue
            boardNode.addChildNode(voxelNode)
        }
        currentLevel = index
        currentGameBoardNode = boardNode
        
        let pieces = Voxxle.instance.pieces(forLevelAtIndex: index)
        for i in 0..<pieces.count {
            let piece = pieces[i]
            let content = SCNNode()
            let texture = UIImage(named: Art.gray)
            for point in piece.points {
                let voxel = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                voxel.firstMaterial?.diffuse.contents = texture
                let voxelNode = SCNNode(geometry: voxel)
                voxelNode.simdPosition = point
                content.addChildNode(voxelNode)
            }
            let pieceObject = ARInteractableObject(named: piece.textureFilename, withContent: content)
            pieceObject.simdPosition = simd_float3(Float(-3*pieces.count/2 + 3*i), 3, 0)
            boardNode.addChildNode(pieceObject)
        }
        
        let node = SCNNode()
        node.position = SCNVector3(0, 0, -1)
        node.addChildNode(boardNode)
        return node
    }
    
    func showGameNode(forLevel index: Int) {
        guard Voxxle.instance.islevelUnlocked(atIndex: index) else { return }
        mainMenuButton.isHidden = false
        helpButton.isHidden = false
        
        let node = gameNode(forLevel: index)
        if let currentNode = currentNode {
            node.transform = currentNode.transform
            sceneView.scene.rootNode.replaceChildNode(currentNode, with: node)
        }
        currentNode = node
    }
    
}

