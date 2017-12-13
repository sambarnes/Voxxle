//
//  Voxxle.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/14/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//

import SceneKit

/// The model class that holds level structures, level solutions,
/// game piece structures, and persistent user data.
class Voxxle {
    
    /// Singleton instance used to access the model
    static var instance = Voxxle()
    
    // MARK: File-Private variables and constructors
    
    fileprivate var levels = [Level]()
    
    fileprivate let pieceI = [simd_float3(0, 1, 0),simd_float3(0, -1, 0), simd_float3(0, 0, 0)]
    fileprivate let pieceL = [simd_float3(0, 0, 0), simd_float3(0, 1, 0),
                              simd_float3(0, -1, 0), simd_float3(1, -1, 0)]
    fileprivate let pieceU = [simd_float3(1, 1, 0),simd_float3(1, 0, 0),
                              simd_float3(-1, 0, 0), simd_float3(-1, 1, 0),
                              simd_float3(0, 0, 0)]
    fileprivate let pieceCross = [simd_float3(1, 0, 0),simd_float3(-1, 0, 0),
                                  simd_float3(0, 1, 0), simd_float3(0, -1, 0),
                                  simd_float3(0, 0, 1), simd_float3(0, 0, -1),
                                  simd_float3(0, 0, 0)]
    fileprivate let pieceO = [simd_float3(1, 0, 0),simd_float3(-1, 0, 0),
                              simd_float3(0, 1, 0), simd_float3(0, -1, 0),
                              simd_float3(1, 1, 0), simd_float3(-1, 1, 0),
                              simd_float3(1, -1, 0), simd_float3(-1, -1, 0)]
    fileprivate let pieceS = [simd_float3(0, 1, 0), simd_float3(0, -1, 0),
                              simd_float3(1, 1, 0), simd_float3(-1, -1, 0),
                              simd_float3(0, 0, 0)]
    fileprivate let piece4Corners = [simd_float3(1, 1, 0), simd_float3(1, -1, 0),
                                     simd_float3(-1, 1, 0), simd_float3(-1, -1, 0)]
    fileprivate let piece2Line = [simd_float3(0, 0, 0), simd_float3(0, 1, 0)]
    fileprivate let pieceP = [simd_float3(0, 0, 0), simd_float3(0, 1, 0),
                              simd_float3(1, 0, 0), simd_float3(1, 1, 0),
                              simd_float3(0, -1, 0)]
    fileprivate let pieceF = [simd_float3(0, 0, 0), simd_float3(0, 1, 0),
                              simd_float3(0, -1, 0), simd_float3(0, -2, 0),
                              simd_float3(1, 1, 0), simd_float3(1, -1, 0)]
    
    fileprivate init() {
        // TODO: Populate levels array from a p-list or JSON file
        
        var level1 = [simd_float3]()
        let range = -1 ... 1
        for i in range {
            for j in range {
                for k in range {
                    level1.append(simd_float3(Float(i), Float(j), Float(k)))
                }
            }
        }
        var level1Pieces = [Piece]()
        level1Pieces.append(Piece(points: pieceI, textureFilename: Art.red))
        level1Pieces.append(Piece(points: pieceU, textureFilename: Art.blue))
        level1Pieces.append(Piece(points: pieceCross, textureFilename: Art.purple))
        level1Pieces.append(Piece(points: pieceO, textureFilename: Art.orange))
        level1Pieces.append(Piece(points: piece4Corners, textureFilename: Art.green))
        levels.append(Level(board: level1, pieces: level1Pieces, isUnlocked: true, hasBeenSolved: false))
        
        var level2 = [simd_float3]()
        for i in [-1, 1] {
            for j in [-1, 0, 1] {
                for k in [-2, -1, 0, 1, 2] {
                    level2.append(simd_float3(Float(i), Float(j), Float(k)))
                }
            }
        }
        var level2Pieces = [Piece]()
        level2Pieces.append(Piece(points: pieceI, textureFilename: Art.red))
        level2Pieces.append(Piece(points: pieceU, textureFilename: Art.blue))
        level2Pieces.append(Piece(points: pieceL, textureFilename: Art.yellow))
        level2Pieces.append(Piece(points: pieceS, textureFilename: Art.cyan))
        level2Pieces.append(Piece(points: piece2Line, textureFilename: Art.pink))
        level2Pieces.append(Piece(points: pieceF, textureFilename: Art.orange))
        level2Pieces.append(Piece(points: pieceP, textureFilename: Art.green))
        levels.append(Level(board: level2, pieces: level2Pieces, isUnlocked: false, hasBeenSolved: false))
        
        var level3 = [simd_float3]()
        for i in -2...1 {
            for j in -1...1 {
                level3.append(simd_float3(Float(i), Float(j), 0))
            }
        }
        level3.append(contentsOf: [simd_float3(2,-1,0), simd_float3(3,-1,0), simd_float3(3,0,0),])
        var level3Pieces = [Piece]()
        level3Pieces.append(Piece(points: pieceU, textureFilename: Art.blue))
        level3Pieces.append(Piece(points: pieceP, textureFilename: Art.blue))
        level3Pieces.append(Piece(points: pieceS, textureFilename: Art.white))
        levels.append(Level(board: level3, pieces: level3Pieces, isUnlocked: false, hasBeenSolved: false))
    }
    
    // MARK: Public properties and functions to access model data
    
    /// Total number of game levels
    var numberOfLevels : Int {
        get {
            return levels.count
        }
    }
    
    /// Returns true if a given level has been unlocked and is ready
    /// for the user to play
    func islevelUnlocked(atIndex index: Int) -> Bool {
        return levels[index].isUnlocked
    }
    
    /// Returns true if a given level has been solved by the user before
    func hasLevelBeenSolved(atIndex index: Int) -> Bool {
        return levels[index].hasBeenSolved
    }
    
    /// Sets the specified level as solved and tries to unlock the next level
    func markLevelSolved(atIndex index: Int) {
        levels[index].hasBeenSolved = true
        if index + 1 < numberOfLevels {
            levels[index + 1].isUnlocked = true
        }
    }
    
    /// Returns an array of points that represent the possible positions
    /// of the given game board
    func gameBoard(forLevelAtIndex index: Int) -> [simd_float3] {
        return levels[index].board
    }
    
    func pieces(forLevelAtIndex index: Int) -> [Piece] {
        return levels[index].pieces
    }
    
}

/// An object that represents an individual game level
class Level {
    var board : [simd_float3]
    var pieces : [Piece]
    var isUnlocked : Bool
    var hasBeenSolved : Bool
    
    init(board: [simd_float3], pieces: [Piece], isUnlocked: Bool, hasBeenSolved: Bool) {
        self.board = board
        self.pieces = pieces
        self.isUnlocked = isUnlocked
        
        // Ensure a locked level cannot be marked as solved
        self.hasBeenSolved = isUnlocked ? hasBeenSolved : false
    }
}

/// An object that represents an individual game piece
class Piece {
    var points : [simd_float3]
    var textureFilename : String
    
    init(points: [simd_float3], textureFilename: String) {
        self.points = points
        self.textureFilename = textureFilename
    }
}
