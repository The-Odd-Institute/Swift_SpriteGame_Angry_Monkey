import SpriteKit
import GameplayKit

import UIKit



// Masks
struct categories
{
    static let bars : UInt32 = UInt32(3)
    
    static let monkeis : UInt32 = UInt32(1)
    static let brick   : UInt32 = UInt32(2)
   
    static let death: UInt32 = UInt32(4)
    static let border: UInt32 = UInt32(5)
}



class GameScene: SKScene
{
    var panGesture: UIPanGestureRecognizer!
    
    var shootCenter: CGPoint!
    
    private var pauseButton: SKSpriteNode!
    private var playButton: SKSpriteNode!
    private var dimmerNode: SKSpriteNode!
    
    
    private var shootCircle: SKSpriteNode!
    private var releasePoint: SKSpriteNode!
    
    private var ballsEmitter: SKEmitterNode!
    private var monkeyNode: SKSpriteNode!
    
    
    
    var curTime : Int = 0;
    var gameTimer : Timer!
    private var timerLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    
    
    private var worldNode: SKNode!
    
    
    override func didMove(to view: SKView)
    {
        let myLabel : UILabel = UILabel(frame: CGRect(x: 20, y: 20, width: 200, height: 50));
        myLabel.text = "Ding";
        self.scene?.view?.addSubview(myLabel);
        
        
        
        
        
        
        buildEmitterReleaseAndCircle()
        buildTimer()
        
        pauseAndDim()
    }
    
    
    func makeNewMonkey ()
    {
        if ( self.monkeyNode != nil)
        {
            self.monkeyNode.physicsBody?.velocity = CGVector.zero
            self.monkeyNode.removeFromParent()
        }
        
        
        self.monkeyNode = SKSpriteNode()
        self.monkeyNode.texture = SKTexture(imageNamed: "monkey.png")
        self.monkeyNode.size = CGSize(width: 128, height: 128)
        addChild(monkeyNode)
        
        self.monkeyNode.physicsBody = SKPhysicsBody.init(rectangleOf: self.monkeyNode.size)
        //
        self.monkeyNode.physicsBody?.restitution = 0.1 // bounciness decay
        self.monkeyNode.physicsBody?.usesPreciseCollisionDetection = true;
        self.monkeyNode.physicsBody?.affectedByGravity = false
        self.monkeyNode.physicsBody?.isDynamic = false
        self.monkeyNode.physicsBody?.mass = 1
        self.monkeyNode.physicsBody?.density = 1
        self.monkeyNode.physicsBody?.friction = 0.1
        self.monkeyNode.physicsBody?.linearDamping = 0
        
        
        // where belong to
        self.monkeyNode.physicsBody?.categoryBitMask = categories.monkeis
        
        // which contacts are detected
        self.monkeyNode.physicsBody?.contactTestBitMask = categories.monkeis
        
        // what does it collide againast
        self.monkeyNode.physicsBody?.collisionBitMask = categories.monkeis
        self.monkeyNode.zPosition = 5;
    }

    
    func buildEmitterReleaseAndCircle()
    {
        ballsEmitter = self.childNode(withName: "//ballsEmitter_id") as! SKEmitterNode;
        shootCenter = ballsEmitter.position
        ballsEmitter.zPosition = 2
        ballsEmitter.particleBirthRate = 5
        ballsEmitter.isHidden = true

        releasePoint = SKSpriteNode(imageNamed: "releasePoint.png")
        releasePoint.position = shootCenter
        releasePoint.size = CGSize(width: 128, height: 128)
        addChild(releasePoint)
        releasePoint.isHidden = true
        releasePoint.zPosition = 4
        
        shootCircle = SKSpriteNode(imageNamed: "shootCircle.png")
        shootCircle.position = shootCenter
        addChild(shootCircle)
        shootCircle.isHidden = true
        shootCircle.zPosition = 3
    }
    

    
    func pauseAndDim ()
    {
        self.pauseButton = self.childNode(withName: "//pauseButton_id") as! SKSpriteNode;
        pauseButton.zPosition = 10
        
        self.dimmerNode = self.childNode(withName: "//dimmer_id") as! SKSpriteNode;
        self.dimmerNode.isHidden = true
    }
    
    func buildTimer()
    {
        self.timerLabel = self.childNode(withName: "//timerLabel_id") as! SKLabelNode;
        self.scoreLabel = self.childNode(withName: "//scoreLabel_id") as! SKLabelNode;
        
        curTime = 0;
        gameTimer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(timerFunc),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if ( super.isPaused )
        {
            return
        }
        
        let myTouch: UITouch = touches.first!
        let loc: CGPoint = myTouch.location(in: self)
        
        if pauseButton.contains(loc)
        {
            // pause the game
            super.isPaused = true
            
            self.playButton = SKSpriteNode(imageNamed: "playButton.png")
            playButton.zPosition = 10
            self.addChild(playButton)
            
            pauseButton.alpha = 0.5
            self.dimmerNode.isHidden = false
        }
        else
        {
            makeNewMonkey()
            ballsEmitter.isHidden = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ( super.isPaused)
        {
            return
        }
        
        
        let myTouch : UITouch = touches.first!
        
        let curL = myTouch.location(in: self)
        
        let angle : CGFloat = atan2(shootCenter.y - curL.y, shootCenter.x - curL.x) - atan2(0, 1)
        let dist : CGFloat = sqrt(pow(curL.y-shootCenter.y, 2) + pow(curL.x-shootCenter.x, 2))

        var shootCircleW = dist * 2
        
        if (shootCircleW > 300)
        {
            shootCircleW = 300
        }
        else if (shootCircleW < 50)
        {
            shootCircleW = 50
        }
        
        
        
        
        let dir : CGVector = CGVector(dx: curL.x-shootCenter.x,
                                      dy: curL.y-shootCenter.y).normalized()
        let releasePointLoc: CGPoint = CGPoint(x: dir.dx * shootCircleW / 2 + shootCenter.x,
                                               y: dir.dy * shootCircleW / 2 + shootCenter.y )
        releasePoint.zRotation = angle
        
        releasePoint.position = releasePointLoc
        releasePoint.isHidden = false
        
        let monkeyLoc: CGPoint = CGPoint(x: dir.dx * shootCircleW / 2.5 + shootCenter.x,
                                         y: dir.dy * shootCircleW / 2.5 + shootCenter.y )
        monkeyNode.position = monkeyLoc
        
        shootCircle.size = CGSize(width: shootCircleW, height: shootCircleW)
        shootCircle.isHidden = false
        
        ballsEmitter.particleLifetime = 3 - dist / 500
        ballsEmitter.emissionAngle = angle
        ballsEmitter.particleSpeed = dist
        
        ballsEmitter.position = CGPoint(x: shootCenter.x, y: shootCenter.y)
    }
    

   
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        run(SKAction.playSoundFileNamed("Beep1.wav", waitForCompletion: false))

        
        ballsEmitter.isHidden = true
        
        let myTouch: UITouch = touches.first!
        let finalTouchLoc = myTouch.location(in: self)
        
        if playButton != nil && playButton.contains(finalTouchLoc)
        {
            // re - play the game
            super.isPaused = false
            pauseButton.alpha = 1
            
            self.playButton.removeFromParent()
            self.playButton = nil
            self.dimmerNode.isHidden = true
            return
        }
        else if (super.isPaused)
        {
            print("in ended is paused")
            return
        }
        
        self.monkeyNode.physicsBody?.affectedByGravity = true
        self.monkeyNode.physicsBody?.isDynamic = true
        
        shootCircle.isHidden = true
        releasePoint.isHidden = true
        
        
        ballsEmitter.particleBirthRate = 0
        
 
        let angle : CGVector = CGVector(dx: shootCenter.x - finalTouchLoc.x,
                                        dy: shootCenter.y - finalTouchLoc.y ).normalized()
        
        let forceVal : CGFloat = 200 * sqrt(pow(finalTouchLoc.y-shootCenter.y, 2) + pow(finalTouchLoc.x-shootCenter.x, 2))
        
        let force : CGVector = CGVector (dx: angle.dx * forceVal, dy: angle.dy * forceVal)
        
        monkeyNode.physicsBody?.applyForce(force)
    }
    
    
    @objc func timerFunc()
    {
        if ( !super.isPaused)
        {
            curTime += 1;
            let timeMins: Int = abs(curTime / 60);
            let timeSecs: Int = curTime % 60;
            
            let timeStr = NSString(format:"%02d\':%02d\"", timeMins, timeSecs);
            
            timerLabel.text = timeStr as String;
        }
    }
    
    
    override func update(_ currentTime: TimeInterval)
    {
    }
}


extension CGVector
{
    func length() -> CGFloat
    {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector
    {
        return CGVector(dx: self.dx / length(), dy:self.dy / length())
    }
}
