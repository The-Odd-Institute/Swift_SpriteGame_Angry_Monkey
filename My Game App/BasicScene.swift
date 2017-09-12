import SpriteKit
import GameplayKit


// Collision Detection
struct cats {
    static let collideOnly : UInt32 = UInt32(1)
    static let contactOnly   : UInt32 = UInt32(2)
    static let collideAndContact: UInt32 = UInt32(3)
    static let none: UInt32 = UInt32(4)
}


class BasicScene: SKScene, SKPhysicsContactDelegate {
    
    
    var boxNode : SKSpriteNode!
    var bar1_Node : SKSpriteNode!
    var bar2_Node : SKSpriteNode!
    
    
    var monkey : SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        
        self.monkey = self.childNode(withName: "//monkey_id") as! SKSpriteNode;
        self.monkey.physicsBody = SKPhysicsBody.init(rectangleOf: monkey.frame.size)
        
        // doesn't re-act to collision
       // self.monkey.physicsBody?.isDynamic = false;
        self.monkey.physicsBody?.restitution = 0
        
        
        // every physic body
        // has a category
        // can come into contact with some others in a category
        // can come into collision with some others
        
        
        
        
        
        // category
        self.monkey.physicsBody?.categoryBitMask = cats.collideAndContact
        // collision
        
        // contact
        

        
        
        backgroundColor = UIColor.darkGray
        
        self.boxNode = self.childNode(withName: "//boxNode_id") as! SKSpriteNode;
        self.boxNode.physicsBody = SKPhysicsBody.init(rectangleOf: self.boxNode.frame.size)
        self.boxNode.physicsBody?.restitution = 1
        self.boxNode.physicsBody?.usesPreciseCollisionDetection = true;
        
        self.boxNode.physicsBody?.categoryBitMask = cats.collideAndContact
        
        self.boxNode.physicsBody?.contactTestBitMask = cats.collideAndContact
        self.boxNode.physicsBody?.collisionBitMask = cats.collideAndContact
        self.boxNode.physicsBody?.affectedByGravity = true
        self.boxNode.zPosition = 1000
        self.boxNode.physicsBody?.isDynamic = true
        
        
        
        self.bar1_Node = self.childNode(withName: "//bar1_id") as! SKSpriteNode;
        
        
        
        
        
        // come back here
        
        
        let scaleAction : SKAction = SKAction.scale(to: 0.1, duration: 0.5)
        let fadeOutAction: SKAction = SKAction.fadeOut(withDuration: 0.5)
        let actionSequence = SKAction.sequence([scaleAction,
                                                fadeOutAction])
        
        self.bar1_Node.run(actionSequence)
        
        
        
        

        self.bar2_Node = self.childNode(withName: "//bar2_id") as! SKSpriteNode;

        let moveAction : SKAction = SKAction(named: "MoveIt")!

        self.bar2_Node.run(moveAction)
        
        
        
        
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)

    }
    
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        run(SKAction.playSoundFileNamed("Beep1.wav", waitForCompletion: false))
        
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        let firstNode = firstBody.node
        let secondNode = secondBody.node
        
        
        if ( firstBody.categoryBitMask == cats.contactOnly )
        {
            // act like a trigger
        }
        else if ( firstBody.categoryBitMask == cats.collideAndContact )
        {
            // collide and send a contact
        }
        else
        {
            // this will almost never happen
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        
    }
}
