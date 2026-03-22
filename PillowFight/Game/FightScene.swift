import SpriteKit

class FightScene: SKScene {
    
    // Fighters
    var player1: FighterNode!
    var player2: FighterNode!
    
    // AI
    private var aiController = AIController()
    
    // Characters
    var player1Character: GameCharacter = .theo
    var player2Character: GameCharacter = .ben
    
    // Game state
    var isRoundActive = false
    private var lastUpdateTime: TimeInterval = 0
    
    // UI elements
    private var p1HealthBar: SKShapeNode!
    private var p1HealthFill: SKShapeNode!
    private var p2HealthBar: SKShapeNode!
    private var p2HealthFill: SKShapeNode!
    private var roundLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var announcementLabel: SKLabelNode!
    private var p1SpecialIndicator: SKShapeNode!
    private var p2SpecialIndicator: SKShapeNode!
    
    // Round state
    var roundTimer: TimeInterval = 60
    var currentRound: Int = 1
    
    // Callbacks
    var onRoundEnd: ((Bool) -> Void)?  // true = player1 wins round
    var onHealthUpdate: ((CGFloat, CGFloat) -> Void)?
    
    // Constants
    private let groundY: CGFloat = 80
    private let arenaMinX: CGFloat = 30
    private var arenaMaxX: CGFloat { size.width - 30 }
    
    // Background
    private var backgroundNode: SKNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.1, blue: 0.25, alpha: 1.0)
        buildArena()
        buildUI()
        setupFighters()
        startRound()
    }
    
    private func buildArena() {
        backgroundNode = SKNode()
        
        // Floor
        let floor = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: groundY - 10))
        floor.fillColor = SKColor(red: 0.3, green: 0.2, blue: 0.15, alpha: 1.0)
        floor.strokeColor = .clear
        backgroundNode.addChild(floor)
        
        // Floor pattern (wooden planks)
        for i in 0..<Int(size.width / 40) {
            let plank = SKShapeNode(rect: CGRect(x: CGFloat(i) * 40 + 2, y: 5, width: 36, height: groundY - 18), cornerRadius: 2)
            plank.fillColor = SKColor(red: 0.45, green: 0.3, blue: 0.2, alpha: 1.0)
            plank.strokeColor = SKColor(red: 0.35, green: 0.2, blue: 0.1, alpha: 0.5)
            plank.lineWidth = 1
            backgroundNode.addChild(plank)
        }
        
        // Wall
        let wall = SKShapeNode(rect: CGRect(x: 0, y: groundY - 10, width: size.width, height: size.height - groundY + 10))
        wall.fillColor = SKColor(red: 0.2, green: 0.15, blue: 0.3, alpha: 1.0)
        wall.strokeColor = .clear
        backgroundNode.addChild(wall)
        
        // Window on wall
        let window = SKShapeNode(rect: CGRect(x: size.width / 2 - 40, y: size.height - 160, width: 80, height: 60), cornerRadius: 5)
        window.fillColor = SKColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 0.8)
        window.strokeColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
        window.lineWidth = 4
        backgroundNode.addChild(window)
        
        // Moon in window
        let moon = SKShapeNode(circleOfRadius: 12)
        moon.position = CGPoint(x: size.width / 2 + 10, y: size.height - 120)
        moon.fillColor = SKColor(red: 1, green: 1, blue: 0.8, alpha: 0.9)
        moon.strokeColor = .clear
        backgroundNode.addChild(moon)
        
        // Stars in window
        for _ in 0..<5 {
            let star = SKLabelNode(text: "⭐")
            star.fontSize = 6
            star.position = CGPoint(
                x: CGFloat.random(in: (size.width/2 - 35)...(size.width/2 + 35)),
                y: CGFloat.random(in: (size.height - 155)...(size.height - 110))
            )
            backgroundNode.addChild(star)
        }
        
        // Pillows scattered on floor (decoration)
        let decorPillowPositions: [CGPoint] = [
            CGPoint(x: 60, y: groundY - 15),
            CGPoint(x: size.width - 80, y: groundY - 12),
            CGPoint(x: size.width / 2 + 50, y: groundY - 18)
        ]
        let pillowColors: [UIColor] = [.systemPink, .systemCyan, .systemYellow]
        
        for (i, pos) in decorPillowPositions.enumerated() {
            let pillow = SKShapeNode(rect: CGRect(x: -10, y: -6, width: 20, height: 12), cornerRadius: 5)
            pillow.position = pos
            pillow.fillColor = pillowColors[i % pillowColors.count]
            pillow.strokeColor = pillowColors[i % pillowColors.count].darker()
            pillow.zRotation = CGFloat.random(in: -0.3...0.3)
            backgroundNode.addChild(pillow)
        }
        
        // Bed in background
        let bedFrame = SKShapeNode(rect: CGRect(x: 20, y: groundY - 10, width: 100, height: 50), cornerRadius: 5)
        bedFrame.fillColor = SKColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 0.5)
        bedFrame.strokeColor = SKColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 0.5)
        bedFrame.lineWidth = 2
        backgroundNode.addChild(bedFrame)
        
        addChild(backgroundNode)
    }
    
    private func buildUI() {
        let barWidth: CGFloat = 140
        let barHeight: CGFloat = 16
        let topY = size.height - 50
        
        // P1 Health Bar background
        p1HealthBar = SKShapeNode(rect: CGRect(x: 0, y: 0, width: barWidth, height: barHeight), cornerRadius: 4)
        p1HealthBar.position = CGPoint(x: 20, y: topY)
        p1HealthBar.fillColor = SKColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0.8)
        p1HealthBar.strokeColor = .white
        p1HealthBar.lineWidth = 2
        addChild(p1HealthBar)
        
        // P1 Health fill
        p1HealthFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: barWidth - 4, height: barHeight - 4), cornerRadius: 3)
        p1HealthFill.fillColor = .systemGreen
        p1HealthFill.strokeColor = .clear
        p1HealthBar.addChild(p1HealthFill)
        
        // P1 Name
        let p1Name = SKLabelNode(text: player1Character.displayName)
        p1Name.fontSize = 14
        p1Name.fontName = "AvenirNext-Bold"
        p1Name.fontColor = player1Character.shirtColor
        p1Name.position = CGPoint(x: 20, y: topY + 20)
        p1Name.horizontalAlignmentMode = .left
        addChild(p1Name)
        
        // P2 Health Bar background
        p2HealthBar = SKShapeNode(rect: CGRect(x: 0, y: 0, width: barWidth, height: barHeight), cornerRadius: 4)
        p2HealthBar.position = CGPoint(x: size.width - barWidth - 20, y: topY)
        p2HealthBar.fillColor = SKColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0.8)
        p2HealthBar.strokeColor = .white
        p2HealthBar.lineWidth = 2
        addChild(p2HealthBar)
        
        // P2 Health fill
        p2HealthFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: barWidth - 4, height: barHeight - 4), cornerRadius: 3)
        p2HealthFill.fillColor = .systemGreen
        p2HealthFill.strokeColor = .clear
        p2HealthBar.addChild(p2HealthFill)
        
        // P2 Name
        let p2Name = SKLabelNode(text: player2Character.displayName)
        p2Name.fontSize = 14
        p2Name.fontName = "AvenirNext-Bold"
        p2Name.fontColor = player2Character.shirtColor
        p2Name.position = CGPoint(x: size.width - 20, y: topY + 20)
        p2Name.horizontalAlignmentMode = .right
        addChild(p2Name)
        
        // Round label
        roundLabel = SKLabelNode(text: "Round \(currentRound)")
        roundLabel.fontSize = 16
        roundLabel.fontName = "AvenirNext-Bold"
        roundLabel.fontColor = .yellow
        roundLabel.position = CGPoint(x: size.width / 2, y: topY + 15)
        addChild(roundLabel)
        
        // Timer
        timerLabel = SKLabelNode(text: "60")
        timerLabel.fontSize = 22
        timerLabel.fontName = "AvenirNext-Bold"
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: size.width / 2, y: topY - 5)
        addChild(timerLabel)
        
        // Announcement label (for FIGHT!, KO!, etc)
        announcementLabel = SKLabelNode(text: "")
        announcementLabel.fontSize = 40
        announcementLabel.fontName = "AvenirNext-Heavy"
        announcementLabel.fontColor = .yellow
        announcementLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        announcementLabel.zPosition = 100
        addChild(announcementLabel)
        
        // Special move indicators
        p1SpecialIndicator = SKShapeNode(circleOfRadius: 12)
        p1SpecialIndicator.position = CGPoint(x: 170, y: topY + 8)
        p1SpecialIndicator.fillColor = .yellow
        p1SpecialIndicator.strokeColor = .orange
        p1SpecialIndicator.lineWidth = 2
        addChild(p1SpecialIndicator)
        
        let p1SpecialLabel = SKLabelNode(text: "S")
        p1SpecialLabel.fontSize = 12
        p1SpecialLabel.fontName = "AvenirNext-Bold"
        p1SpecialLabel.fontColor = .black
        p1SpecialLabel.verticalAlignmentMode = .center
        p1SpecialIndicator.addChild(p1SpecialLabel)
        
        p2SpecialIndicator = SKShapeNode(circleOfRadius: 12)
        p2SpecialIndicator.position = CGPoint(x: size.width - barWidth - 40, y: topY + 8)
        p2SpecialIndicator.fillColor = .yellow
        p2SpecialIndicator.strokeColor = .orange
        p2SpecialIndicator.lineWidth = 2
        addChild(p2SpecialIndicator)
        
        let p2SpecialLabel = SKLabelNode(text: "S")
        p2SpecialLabel.fontSize = 12
        p2SpecialLabel.fontName = "AvenirNext-Bold"
        p2SpecialLabel.fontColor = .black
        p2SpecialLabel.verticalAlignmentMode = .center
        p2SpecialIndicator.addChild(p2SpecialLabel)
    }
    
    private func setupFighters() {
        player1 = FighterNode(character: player1Character, isPlayer1: true, groundY: groundY)
        player1.position = CGPoint(x: size.width * 0.25, y: groundY)
        player1.zPosition = 10
        addChild(player1)
        
        player2 = FighterNode(character: player2Character, isPlayer1: false, groundY: groundY)
        player2.position = CGPoint(x: size.width * 0.75, y: groundY)
        player2.zPosition = 10
        addChild(player2)
    }
    
    func startRound() {
        isRoundActive = false
        roundTimer = 60
        player1.health = 100
        player2.health = 100
        
        player1.position = CGPoint(x: size.width * 0.25, y: groundY)
        player2.position = CGPoint(x: size.width * 0.75, y: groundY)
        
        player1.setFacing(right: true)
        player2.setFacing(right: false)
        
        roundLabel.text = "Round \(currentRound)"
        
        updateHealthBars()
        
        // Countdown animation
        showAnnouncement("ROUND \(currentRound)") { [weak self] in
            self?.showAnnouncement("FIGHT!") { [weak self] in
                self?.isRoundActive = true
                self?.announcementLabel.text = ""
            }
        }
    }
    
    private func showAnnouncement(_ text: String, completion: @escaping () -> Void) {
        announcementLabel.text = text
        announcementLabel.setScale(0.1)
        announcementLabel.alpha = 1.0
        
        let grow = SKAction.scale(to: 1.2, duration: 0.3)
        let shrink = SKAction.scale(to: 1.0, duration: 0.1)
        let hold = SKAction.wait(forDuration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        
        announcementLabel.run(SKAction.sequence([grow, shrink, hold, fadeOut])) {
            completion()
        }
    }
    
    // MARK: - Player input
    
    func playerMoveLeft() {
        guard isRoundActive else { return }
        player1.velocityX = -player1.moveSpeed
        player1.setFacing(right: false)
    }
    
    func playerMoveRight() {
        guard isRoundActive else { return }
        player1.velocityX = player1.moveSpeed
        player1.setFacing(right: true)
    }
    
    func playerStopMoving() {
        player1.velocityX = 0
    }
    
    func playerJump() {
        guard isRoundActive else { return }
        player1.executeMove(.jump)
    }
    
    func playerPillowSwing() {
        guard isRoundActive else { return }
        player1.executeMove(.pillowSwing)
        checkHit(attacker: player1, defender: player2, move: .pillowSwing)
    }
    
    func playerKick() {
        guard isRoundActive else { return }
        player1.executeMove(.kick)
        checkHit(attacker: player1, defender: player2, move: .kick)
    }
    
    func playerSpecial() {
        guard isRoundActive else { return }
        player1.executeMove(.special)
        // Special has delayed hit
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.checkHit(attacker: self.player1, defender: self.player2, move: .special)
            }
        ]))
    }
    
    // MARK: - Combat
    
    private func checkHit(attacker: FighterNode, defender: FighterNode, move: MoveType) {
        let distance = abs(attacker.position.x - defender.position.x)
        
        if distance <= move.range {
            var damage = move.damage
            
            // Random variance
            damage += CGFloat.random(in: -2...2)
            
            defender.health -= damage
            defender.animateHit()
            
            // Show damage number
            showDamageNumber(Int(damage), at: defender.position)
            
            // Spawn hit effect
            spawnHitEffect(at: CGPoint(
                x: (attacker.position.x + defender.position.x) / 2,
                y: defender.position.y + 30
            ))
            
            updateHealthBars()
            onHealthUpdate?(player1.health, player2.health)
            
            // Check for KO
            if defender.health <= 0 {
                defender.health = 0
                endRound(winner: attacker === player1)
            }
        }
    }
    
    private func showDamageNumber(_ damage: Int, at position: CGPoint) {
        let label = SKLabelNode(text: "-\(damage)")
        label.fontSize = 18
        label.fontName = "AvenirNext-Bold"
        label.fontColor = .red
        label.position = CGPoint(x: position.x, y: position.y + 50)
        label.zPosition = 50
        addChild(label)
        
        let moveUp = SKAction.moveBy(x: CGFloat.random(in: -15...15), y: 30, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        label.run(SKAction.sequence([
            SKAction.group([moveUp, fade]),
            SKAction.removeFromParent()
        ]))
    }
    
    private func spawnHitEffect(at position: CGPoint) {
        let effect = SKLabelNode(text: "💥")
        effect.fontSize = 30
        effect.position = position
        effect.zPosition = 50
        addChild(effect)
        
        let grow = SKAction.scale(to: 1.5, duration: 0.1)
        let shrink = SKAction.scale(to: 0.5, duration: 0.2)
        let fade = SKAction.fadeOut(withDuration: 0.1)
        effect.run(SKAction.sequence([grow, shrink, fade, SKAction.removeFromParent()]))
    }
    
    private func updateHealthBars() {
        let barWidth: CGFloat = 136  // Inner width
        
        let p1Pct = max(player1.health / 100, 0)
        let p2Pct = max(player2.health / 100, 0)
        
        // Update P1 health fill
        p1HealthFill.removeFromParent()
        p1HealthFill = SKShapeNode(rect: CGRect(x: 2, y: 2, width: barWidth * p1Pct, height: 12), cornerRadius: 3)
        p1HealthFill.fillColor = healthColor(for: p1Pct)
        p1HealthFill.strokeColor = .clear
        p1HealthBar.addChild(p1HealthFill)
        
        // Update P2 health fill
        p2HealthFill.removeFromParent()
        let p2Width = barWidth * p2Pct
        p2HealthFill = SKShapeNode(rect: CGRect(x: barWidth - p2Width + 2, y: 2, width: p2Width, height: 12), cornerRadius: 3)
        p2HealthFill.fillColor = healthColor(for: p2Pct)
        p2HealthFill.strokeColor = .clear
        p2HealthBar.addChild(p2HealthFill)
        
        // Update special indicators
        p1SpecialIndicator.fillColor = player1.isSpecialReady ? .yellow : .gray
        p2SpecialIndicator.fillColor = player2.isSpecialReady ? .yellow : .gray
    }
    
    private func healthColor(for percentage: CGFloat) -> SKColor {
        if percentage > 0.5 {
            return .systemGreen
        } else if percentage > 0.25 {
            return .systemYellow
        } else {
            return .systemRed
        }
    }
    
    private func endRound(winner player1Won: Bool) {
        isRoundActive = false
        
        let loser = player1Won ? player2! : player1!
        loser.animateKO()
        
        let winnerName = player1Won ? player1Character.displayName : player2Character.displayName
        
        showAnnouncement("KO!") { [weak self] in
            self?.showAnnouncement("\(winnerName) WINS!") { [weak self] in
                self?.onRoundEnd?(player1Won)
            }
        }
    }
    
    // MARK: - Update loop
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard isRoundActive else { return }
        
        // Update timer
        roundTimer -= deltaTime
        timerLabel.text = "\(max(Int(roundTimer), 0))"
        
        if roundTimer <= 0 {
            // Time's up - whoever has more health wins
            endRound(winner: player1.health >= player2.health)
            return
        }
        
        // Timer color warning
        if roundTimer <= 10 {
            timerLabel.fontColor = .red
        } else {
            timerLabel.fontColor = .white
        }
        
        // Update fighters
        player1.update(deltaTime: deltaTime)
        player2.update(deltaTime: deltaTime)
        
        // Clamp positions to arena
        player1.position.x = max(arenaMinX, min(arenaMaxX, player1.position.x))
        player2.position.x = max(arenaMinX, min(arenaMaxX, player2.position.x))
        
        // Face each other
        if !player1.isExecutingMove {
            player1.setFacing(right: player1.position.x < player2.position.x)
        }
        if !player2.isExecutingMove {
            player2.setFacing(right: player2.position.x < player1.position.x)
        }
        
        // AI control for player 2
        aiController.update(deltaTime: deltaTime, aiFighter: player2, playerFighter: player1, sceneWidth: size.width)
        
        // Check AI attacks
        if player2.isExecutingMove && player2.currentMove != .idle {
            checkHit(attacker: player2, defender: player1, move: player2.currentMove)
        }
        
        // Update health bars
        updateHealthBars()
    }
}
