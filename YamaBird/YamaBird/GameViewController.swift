//
//  GameViewController.swift
//  YamaBird
//
//  Created by Andrew Yamasaki on 9/22/24.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as? SKView {
            // Create the scene programmatically without loading the .sks file
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill

            // Present the scene
            view.presentScene(scene)
            
            // Show FPS and node count (can be removed later)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}


