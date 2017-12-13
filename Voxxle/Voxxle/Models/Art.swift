//
//  Art.swift
//  Voxxle
//
//  Created by Sam Barnes on 11/15/17.
//  Copyright © 2017 Sam Barnes. All rights reserved.
//

import SceneKit

/// The model class that holds convenience accessors for game-piece textures,
/// and other art assets
class Art {
    
    /// Singleton instance used to access the model
    static var instance = Art()
    
    static let red = "red_texture"
    static let orange = "orange_texture"
    static let yellow = "yellow_texture"
    static let pink = "pink_texture"
    static let purple = "purple_texture"
    static let blue = "blue_texture"
    static let cyan = "cyan_texture"
    static let green = "green_texture"
    static let white = "white_texture"
    static let gray = "gray_texture"
    
    fileprivate let cubeTextures = [ "red_texture", "orange_texture", "green_texture",
                                     "yellow_texture", "pink_texture", "purple_texture",
                                     "blue_texture", "cyan_texture", "white_texture" ]
    
    /// Returns a random game-piece texture
    func randomCubeTexture() -> String {
        let index = randomNumber(from: 0, to: cubeTextures.count)
        return cubeTextures[index]
    }
    
    // MARK: File-Private utility functions
    
    fileprivate func randomNumber(from low : Int, to high : Int) -> Int {
        let adjustedMaximum = UInt32(high - low)
        return Int(arc4random_uniform(adjustedMaximum)) + low
    }
}
