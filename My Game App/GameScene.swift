import SpriteKit
import GameplayKit



// Collision / Contact Categories
struct categories {
    static let bars : UInt32 = UInt32(3)
    
    static let monkeis : UInt32 = UInt32(1)
    static let brick   : UInt32 = UInt32(2)       // 1
    //    static let raquete: UInt32 = UInt32(3)
    static let death: UInt32 = UInt32(4)
    static let border: UInt32 = UInt32(5)
}



class GameScene: SKScene {
    
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
    
    func makeNewMonkey ()
    {
        if ( self.monkeyNode != nil)
        {
            self.monkeyNode.removeFromParent()
            self.monkeyNode.physicsBody?.velocity = CGVector.zero
        }
        
        
        self.monkeyNode = SKSpriteNode()
        self.monkeyNode.texture = SKTexture(imageNamed: "monkey.png")
        self.monkeyNode.size = CGSize(width: 128, height: 128)
        addChild(monkeyNode)
        //        self.monkeyNode.isHidden = true
        
        self.monkeyNode.physicsBody = SKPhysicsBody.init(rectangleOf: self.monkeyNode.size)
        //
        self.monkeyNode.physicsBody?.restitution = 0.1
        self.monkeyNode.physicsBody?.usesPreciseCollisionDetection = true;
        self.monkeyNode.physicsBody?.affectedByGravity = false
        self.monkeyNode.physicsBody?.isDynamic = false
        self.monkeyNode.physicsBody?.mass = 1
        self.monkeyNode.physicsBody?.density = 1
        self.monkeyNode.physicsBody?.friction = 0.1
        self.monkeyNode.physicsBody?.linearDamping = 0
        
        // belong to
        self.monkeyNode.physicsBody?.categoryBitMask = categories.monkeis
        
        // interaction notification
        self.monkeyNode.physicsBody?.contactTestBitMask = categories.monkeis
        
        // which can collide with
        self.monkeyNode.physicsBody?.collisionBitMask = categories.monkeis
        
        self.monkeyNode.zPosition = 5;
    }
    
    
    
    
    func buildTheWorld ()    {
        self.view?.isMultipleTouchEnabled = true
        
        self.worldNode = self.childNode(withName: "//worldNode_id") as SKNode!

    }
    
    func buildEmitter() {
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
    
    override func didMove(to view: SKView) {
        
        buildTheWorld()
        buildEmitter()
        pauseAndDimmer()
        
        buildTimer()
    }
    
    func pauseAndDimmer () {
        self.pauseButton = self.childNode(withName: "//pauseButton_id") as! SKSpriteNode;
        
        pauseButton.zPosition = 10
        
        self.dimmerNode = self.childNode(withName: "//dimmer_id") as! SKSpriteNode;
        self.dimmerNode.isHidden = true
    }
    
    func buildTimer()    {
        self.timerLabel = self.childNode(withName: "//timerLabel_id") as! SKLabelNode;
        self.scoreLabel = self.childNode(withName: "//scoreLabel_id") as! SKLabelNode;
        
        curTime = 0;
        gameTimer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(timerFunc),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if ( super.isPaused ) {
            return
        }
        
        let myTouch: UITouch = touches.first!
        let loc: CGPoint = myTouch.location(in: self)
        
        if pauseButton.contains(loc)  {
            // pause the game
            super.isPaused = true
            
            self.playButton = SKSpriteNode(imageNamed: "playButton.png")
            playButton.zPosition = 10
            self.addChild(playButton)
            
            pauseButton.alpha = 0.5
            self.dimmerNode.isHidden = false
        }
        else {
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
        
        //        print("dist is \(dist)")
        
        var shootCircleW = dist * 2
        
        if (shootCircleW > 300) {
            shootCircleW = 300
        } else if (shootCircleW < 50) {
            shootCircleW = 50
        }
        
        
        let dir : CGVector = CGVector(dx: curL.x-shootCenter.x, dy: curL.y-shootCenter.y).normalized()
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
    
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //        if touches.count != 1
        //        {
        //            return
        //        }
        
        
        ballsEmitter.isHidden = true
        
        let myTouch: UITouch = touches.first!
        let finalL = myTouch.location(in: self)
        
        if playButton != nil && playButton.contains(finalL)
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
        
        
        
        
        let angle : CGVector = CGVector(dx: shootCenter.x - finalL.x, dy: shootCenter.y - finalL.y ).normalized()
        
        let forceVal : CGFloat = 200 * sqrt(pow(finalL.y-shootCenter.y, 2) + pow(finalL.x-shootCenter.x, 2))
        
        let force : CGVector = CGVector (dx: angle.dx * forceVal, dy: angle.dy * forceVal)
        
        monkeyNode.physicsBody?.applyForce(force)
    }
    
    
    @objc func timerFunc()    {
        
        if ( !super.isPaused)        {
            curTime += 1;
            let timeMins: Int = abs(curTime / 60);
            let timeSecs: Int = curTime % 60;
            
            let timeStr = NSString(format:"%02d\':%02d\"", timeMins, timeSecs);
            
            timerLabel.text = timeStr as String;
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
    }
}

extension Double {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
    var radiansToDegrees: Double { return Double(self) * 180 / .pi }
}

extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector {
        return CGVector(dx: self.dx / length(), dy:self.dy / length())
    }
}
