import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            // Load the SKScene from 'GameScene.sks'
            
            
//// ANGRY MONKEY SCENE
//            if let scene = SKScene(fileNamed: "GameScene") {
//                scene.scaleMode = .aspectFill
//                view.presentScene(scene)
//            }
            
            
            // THE BASIC SCENE
            if let scene = SKScene(fileNamed: "BasicScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }
            
            
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    
    
    
    
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
