import SpriteKit

// Define physics categories
struct PhysicsCategory {
    static let bird: UInt32 = 1
    static let pipe: UInt32 = 2
    static let ground: UInt32 = 3
    static let scoreZone: UInt32 = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Nodes
    var bird: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var ground1: SKSpriteNode!
    var ground2: SKSpriteNode!
    
    // Game state
    var score = 0
    var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    var gameStarted = false
    var isGameOver = false
    
    // Sound actions
    var flapSound: SKAction!
    var scoreSound: SKAction!
    var hitSound: SKAction!
    var gameOverSound: SKAction!
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupSounds()
        setupBackground()
        setupBird()
        setupLabels()
        setupGround()
        
        addStartLabel()
        configurePhysics()
    }
    
    func setupSounds() {
        flapSound = SKAction.playSoundFileNamed("flap.mp3", waitForCompletion: false)
        scoreSound = SKAction.playSoundFileNamed("score.mp3", waitForCompletion: false)
        hitSound = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
        gameOverSound = SKAction.playSoundFileNamed("gameover.mp3", waitForCompletion: false)
    }
    
    func setupBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background.png")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.size = self.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
    }
    
    func setupBird() {
        let birdTexture = SKTexture(imageNamed: "bird1.png")
        bird = SKSpriteNode(texture: birdTexture)
        bird.size = CGSize(width: birdTexture.size().width / 2, height: birdTexture.size().height / 2)
        bird.position = CGPoint(x: frame.midX, y: frame.midY)
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.pipe | PhysicsCategory.ground
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground
        bird.physicsBody?.affectedByGravity = false
        addChild(bird)
    }
    
    func setupLabels() {
        scoreLabel = createLabel(text: "Score: 0", fontSize: 30, color: .white, position: CGPoint(x: frame.midX, y: frame.maxY - 60))
        highScoreLabel = createLabel(text: "High Score: \(highScore)", fontSize: 16, color: .gray, position: CGPoint(x: frame.minX + 60, y: frame.maxY - 40))
        addChild(scoreLabel)
        addChild(highScoreLabel)
    }
    
    func createLabel(text: String, fontName: String = "Helvetica", fontSize: CGFloat, color: SKColor, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = fontName
        label.fontSize = fontSize
        label.fontColor = color
        label.position = position
        return label
    }
    
    func addStartLabel() {
        let startLabel = createLabel(text: "Tap to Start", fontSize: 30, color: .white, position: CGPoint(x: frame.midX, y: frame.midY - 100))
        startLabel.name = "startLabel"
        addChild(startLabel)
    }
    
    func configurePhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -13)
    }
    
    // MARK: - User Input Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name == "restart" {
                restartGame()
            } else {
                handleGameStartOrFlap()
            }
        }
    }
    
    func handleGameStartOrFlap() {
        run(flapSound)
        
        if !gameStarted {
            startGame()
        }
        
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
    }
    
    func startGame() {
        gameStarted = true
        bird.physicsBody?.affectedByGravity = true
        childNode(withName: "startLabel")?.removeFromParent()
        startGroundMovement()
        startPipeSpawning()
    }
    
    // MARK: - Physics Contact Handling
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.bird | PhysicsCategory.ground || collision == PhysicsCategory.bird | PhysicsCategory.pipe {
            handleGameOver()
        } else if collision == PhysicsCategory.bird | PhysicsCategory.scoreZone {
            increaseScore()
            removeScoreZone(contact)
        }
    }
    
    // MARK: - Game Update
    override func update(_ currentTime: TimeInterval) {
        guard gameStarted else { return }  // Ensure the game has started
        
        let velocityY = bird.physicsBody?.velocity.dy ?? 0
        let maxTiltAngle: CGFloat = 0.5  // Max tilt in radians
        let minTiltAngle: CGFloat = -0.5  // Min tilt in radians
        
        // Calculate the target tilt based on velocity
        let targetTilt = max(min(velocityY / 300, maxTiltAngle), minTiltAngle)  // Use a larger divisor for smoother transitions
        
        // Interpolate between the current rotation and the target tilt for smoother transition
        let tiltSmoothing: CGFloat = 0.1  // Adjust this value for smoother or faster interpolation (0.1 means 10% smoothing per frame)
        bird.zRotation = bird.zRotation * (1 - tiltSmoothing) + targetTilt * tiltSmoothing
    }
    
    func increaseScore() {
        score += 1
        scoreLabel.text = "Score: \(score)"
        run(scoreSound)
    }
    
    func removeScoreZone(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.scoreZone {
            contact.bodyA.node?.removeFromParent()
        } else {
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    func handleGameOver() {
        isGameOver = true
        bird.physicsBody?.categoryBitMask = 0
        bird.physicsBody?.contactTestBitMask = 0
        removeAllActions()
        stopAllMovements()

        // Update high score if the current score is greater
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "HighScore")
            highScoreLabel.text = "High Score: \(highScore)"
        }
        
        // Set up hit sound followed by a 1-second wait, then play the game over sound
        let soundSequence = SKAction.sequence([
            hitSound,
            SKAction.wait(forDuration: 1.5),
            gameOverSound
        ])
        
        run(soundSequence)
        playDeathAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showGameOverScreen()
        }
    }
    
    func stopAllMovements() {
        for node in children where node.physicsBody?.categoryBitMask == PhysicsCategory.pipe || node.name == "ground" {
            node.removeAllActions()
        }
    }
    
    func showGameOverScreen() {
        let boxWidth: CGFloat = 300
        let boxHeight: CGFloat = 250
        let overlay = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: 15)
        overlay.fillColor = SKColor.gray
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 100
        addChild(overlay)
        
        // "Game Over" Label with Helvetica font
        let gameOverLabel = createLabel(text: "Game Over", fontName: "Helvetica", fontSize: 36, color: .red, position: CGPoint(x: 0, y: boxHeight * 0.25))
        overlay.addChild(gameOverLabel)
        
        // Current Score Label (no need for Helvetica here if default font is fine)
        let currentScoreLabel = createLabel(text: "Score: \(score)", fontSize: 24, color: .white, position: CGPoint(x: 0, y: gameOverLabel.position.y - 40))
        overlay.addChild(currentScoreLabel)
        
        // High Score Label (no need for Helvetica here if default font is fine)
        let highScoreLabel = createLabel(text: "High Score: \(highScore)", fontSize: 24, color: .white, position: CGPoint(x: 0, y: currentScoreLabel.position.y - 40))
        overlay.addChild(highScoreLabel)
        
        // Restart Button with Helvetica font
        let restartButton = createLabel(text: "Restart", fontName: "Helvetica", fontSize: 28, color: .green, position: CGPoint(x: 0, y: highScoreLabel.position.y - 60))
        restartButton.name = "restart"
        overlay.addChild(restartButton)
    }

    func restartGame() {
        removeAllActions()
        removeAllChildren()
        gameStarted = false
        score = 0
        didMove(to: view!)
    }
    // MARK: - Pipe and Ground Setup
    func startPipeSpawning() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnPipes()
        }
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnSequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    func spawnPipes() {
        let pipeGap: CGFloat = 150.0  // Space between top and bottom pipes
        let pipeWidth: CGFloat = 60.0  // Width of each pipe
        
        // Calculate the height for the bottom pipe
        let maxBottomPipeHeight = self.frame.height - pipeGap - 100.0
        let bottomPipeHeight = CGFloat.random(in: 100.0...maxBottomPipeHeight)
        
        // Define color for the pipes
        let pipeColor = SKColor.green
        
        // Bottom pipe with shading
        let bottomPipeBody = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: bottomPipeHeight))
        bottomPipeBody.fillColor = pipeColor
        bottomPipeBody.strokeColor = pipeColor
        bottomPipeBody.position = CGPoint(x: self.frame.maxX + pipeWidth / 2, y: self.frame.minY + bottomPipeHeight / 2)
        addPipeShading(to: bottomPipeBody, pipeWidth: pipeWidth, pipeHeight: bottomPipeHeight)
        
        // Bottom pipe cap
        let bottomPipeCap = SKShapeNode(rectOf: CGSize(width: pipeWidth + 10, height: 20), cornerRadius: 10)
        bottomPipeCap.fillColor = pipeColor
        bottomPipeCap.strokeColor = pipeColor
        bottomPipeCap.position = CGPoint(x: 0, y: bottomPipeHeight / 2)
        bottomPipeBody.addChild(bottomPipeCap)
        
        // Top pipe with shading
        let topPipeBody = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: self.frame.height - bottomPipeHeight - pipeGap))
        topPipeBody.fillColor = pipeColor
        topPipeBody.strokeColor = pipeColor
        topPipeBody.position = CGPoint(x: self.frame.maxX + pipeWidth / 2, y: self.frame.maxY - topPipeBody.frame.height / 2)
        addPipeShading(to: topPipeBody, pipeWidth: pipeWidth, pipeHeight: topPipeBody.frame.height)
        
        // Top pipe cap
        let topPipeCap = SKShapeNode(rectOf: CGSize(width: pipeWidth + 10, height: 20), cornerRadius: 10)
        topPipeCap.fillColor = pipeColor
        topPipeCap.strokeColor = pipeColor
        topPipeCap.position = CGPoint(x: 0, y: -topPipeBody.frame.height / 2)
        topPipeBody.addChild(topPipeCap)
        
        // Set up physics bodies for pipes
        bottomPipeBody.physicsBody = SKPhysicsBody(rectangleOf: bottomPipeBody.frame.size)
        bottomPipeBody.physicsBody?.isDynamic = false
        bottomPipeBody.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        
        topPipeBody.physicsBody = SKPhysicsBody(rectangleOf: topPipeBody.frame.size)
        topPipeBody.physicsBody?.isDynamic = false
        topPipeBody.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        
        // Add pipes to the scene
        self.addChild(bottomPipeBody)
        self.addChild(topPipeBody)
        
        // Score zone between pipes
        let scoreZone = SKNode()
        scoreZone.position = CGPoint(x: self.frame.maxX + pipeWidth / 2, y: self.frame.minY + bottomPipeHeight + pipeGap / 2)
        scoreZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: pipeGap))
        scoreZone.physicsBody?.isDynamic = false
        scoreZone.physicsBody?.categoryBitMask = PhysicsCategory.scoreZone
        scoreZone.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        self.addChild(scoreZone)
        
        // Move pipes and score zone
        let moveAction = SKAction.moveBy(x: -self.frame.width - pipeWidth, y: 0, duration: 4.0)
        let removeAction = SKAction.removeFromParent()
        let pipeSequence = SKAction.sequence([moveAction, removeAction])
        bottomPipeBody.run(pipeSequence)
        topPipeBody.run(pipeSequence)
        scoreZone.run(pipeSequence)
    }
    
    // Helper function to add shading to pipes
    func addPipeShading(to pipeBody: SKShapeNode, pipeWidth: CGFloat, pipeHeight: CGFloat) {
        // Lighter shading on the left side
        let leftShade = SKShapeNode(rectOf: CGSize(width: pipeWidth * 0.3, height: pipeHeight))
        leftShade.fillColor = SKColor(white: 1.0, alpha: 0.3)
        leftShade.strokeColor = .clear
        leftShade.position = CGPoint(x: -pipeWidth * 0.35, y: 0)
        pipeBody.addChild(leftShade)
        
        // Darker shading on the right side
        let rightShade = SKShapeNode(rectOf: CGSize(width: pipeWidth * 0.2, height: pipeHeight))
        rightShade.fillColor = SKColor(white: 0.0, alpha: 0.2)
        rightShade.strokeColor = .clear
        rightShade.position = CGPoint(x: pipeWidth * 0.3, y: 0)
        pipeBody.addChild(rightShade)
        
        // Horizontal lines for detail
        let lineColor = SKColor(white: 0.7, alpha: 1.0)
        let line1 = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: 4))
        line1.fillColor = lineColor
        line1.strokeColor = .clear
        line1.position = CGPoint(x: 0, y: pipeHeight * 0.3)
        pipeBody.addChild(line1)
        
        let line2 = SKShapeNode(rectOf: CGSize(width: pipeWidth, height: 4))
        line2.fillColor = lineColor
        line2.strokeColor = .clear
        line2.position = CGPoint(x: 0, y: -pipeHeight * 0.3)
        pipeBody.addChild(line2)
    }
    
    func createScoreZone(pipeGap: CGFloat, bottomPipeHeight: CGFloat) -> SKNode {
        let scoreZone = SKNode()
        scoreZone.position = CGPoint(x: frame.maxX + 30, y: frame.minY + bottomPipeHeight + pipeGap / 2)
        scoreZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: pipeGap))
        scoreZone.physicsBody?.isDynamic = false
        scoreZone.physicsBody?.categoryBitMask = PhysicsCategory.scoreZone
        scoreZone.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        return scoreZone
    }
    
    func startGroundMovement() {
        let groundTexture = SKTexture(imageNamed: "ground")
        let groundMoveDistance = groundTexture.size().width
        let moveSpeed: CGFloat = 115.0
        let moveDuration = TimeInterval(groundMoveDistance / moveSpeed)
        
        enumerateChildNodes(withName: "ground") { node, _ in
            let moveLeft = SKAction.moveBy(x: -groundMoveDistance, y: 0, duration: moveDuration)
            let resetPosition = SKAction.run {
                if node.position.x <= -groundMoveDistance + 20 {
                    node.position.x += groundMoveDistance * CGFloat(self.children.filter { $0.name == "ground" }.count)
                }
            }
            node.run(SKAction.repeatForever(SKAction.sequence([moveLeft, resetPosition])))
        }
    }
    
    func setupGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        let groundSize = CGSize(width: groundTexture.size().width, height: 50)
        let numberOfGrounds = Int(ceil(frame.width / groundTexture.size().width)) + 2
        
        for i in 0..<numberOfGrounds {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.size = groundSize
            ground.position = CGPoint(x: CGFloat(i) * groundTexture.size().width, y: frame.minY + groundSize.height / 2)
            ground.zPosition = 1
            ground.name = "ground"
            addChild(ground)
        }
        
        let groundPhysics = SKNode()
        groundPhysics.position = CGPoint(x: frame.midX, y: frame.minY + groundSize.height / 2)
        groundPhysics.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: groundSize.height))
        groundPhysics.physicsBody?.isDynamic = false
        groundPhysics.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(groundPhysics)
    }
    
    // MARK: - Bird Animation
    func playDeathAnimation() {
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.removeAllActions()
        bird.physicsBody?.allowsRotation = false
        
        let freeze = SKAction.wait(forDuration: 1.5)
        let enableRotation = SKAction.run { [weak self] in
            self?.bird.physicsBody?.allowsRotation = true
        }
        
        let fallDown = SKAction.moveTo(y: frame.minY - bird.size.height, duration: 3.0)
        fallDown.timingMode = .easeIn
        
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.5)
        let continuousRotation = SKAction.repeatForever(rotate)
        
        let deathSequence = SKAction.sequence([freeze, enableRotation, SKAction.group([fallDown, continuousRotation])])
        bird.run(deathSequence) { [weak self] in
            self?.bird.removeFromParent()
        }
    }
}
