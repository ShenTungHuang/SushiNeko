//
//  GameScene.swift
//  SushiNeko
//
//  Created by STH on 2017/5/26.
//  Copyright © 2017年 STH. All rights reserved.
//

import SpriteKit
import GameplayKit

/* Tracking enum for use with character and sushi side */
enum Side
{
    case left, right, none
}

/* Tracking enum for game state */
enum GameState
{
    case title, ready, playing, gameOver
}

class GameScene: SKScene
{
    /* Game objects */
    var sushiBasePiece: SushiPiece!
    var character: Character!
    
    /* Sushi tower array */
    var sushiTower: [SushiPiece] = []
    
    /* Game management */
    var state: GameState = .title
    
    var playButton: MSButtonNode!
    
    var healthBar: SKSpriteNode!
    
    var health: CGFloat = 1.0
    {
        didSet
        {
            /* Cap Health */
            if health > 1.0 { health = 1.0 }
            
            /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
            healthBar.xScale = health
        }
    }
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0
    {
        didSet
        {
            scoreLabel.text = String(score)
        }
    }
    
    var intro: SKSpriteNode!
    
    var titleLabNode: SKLabelNode!
    
    override func didMove(to view: SKView)
    {
        /* Connect game objects */
        sushiBasePiece = childNode(withName: "sushiBasePiece") as! SushiPiece
        character = childNode(withName: "character") as! Character
        
        /* Setup chopstick connections */
        sushiBasePiece.connectChopsticks()
        
        /* Manually stack the start of the tower */
        self.addTowerPiece(side: .none)
        self.addTowerPiece(side: .right)
        
        /* Randomize tower to just outside of the screen */
        self.addRandomPieces(total: 10)
        
        /* UI game objects */
        playButton = childNode(withName: "playButton") as! MSButtonNode
        
        /* Setup play button selection handler */
        playButton.selectedHandler = {
            /* Start game */
            self.state = .title
        }
        
        healthBar = childNode(withName: "healthBar") as! SKSpriteNode
        
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        
        titleLabNode = childNode(withName: "titleLabNode") as! SKLabelNode
        
        intro = childNode(withName: "intro") as! SKSpriteNode
        
        titleLabNode.isHidden = false
    }
    
    
    func touchDown(atPoint pos : CGPoint)
    {}
    
    func touchMoved(toPoint pos : CGPoint)
    {}
    
    func touchUp(atPoint pos : CGPoint)
    {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        /* Called when a touch begins */
        print("\(state)")
        
        /* Game not ready to play */
        if state == .gameOver  { return }
        
        if state == .title
        {
            state = .ready
            
            titleLabNode.isHidden = true
            
            intro.run(SKAction.move(by: CGVector(dx: 0, dy: 550), duration: 1.5))
            
            return
        }
        
        /* Game begins on first touch */
        if state == .ready
        {
            state = .playing
        }
        
        /* We only need a single touch here */
        let touch = touches.first!
        
        /* Get touch position in scene */
        let location = touch.location(in: self)
        
        /* Was touch on left/right hand side of screen? */
        if location.x > 0
        {
            character.side = .right
        }
        else if location.x < 0
        {
            character.side = .left
        }
        
        /* Grab sushi piece on top of the base sushi piece, it will always be 'first' */
        var firstPiece = sushiTower.first as SushiPiece!
        
        let color: UIColor = (firstPiece?.color)!
        
        /* Remove from sushi tower array */
        sushiTower.removeFirst()
        
        /* Animate the punched sushi piece */
        firstPiece?.flip(character.side)
        
        /* Add a new sushi piece to the top of the sushi tower*/
        self.addRandomPieces(total: 1)
        
        /* Drop all the sushi pieces down one place */
        for sushiPiece in sushiTower
        {
            sushiPiece.run(SKAction.move(by: CGVector(dx: 0, dy: -55), duration: 0.10))
            
            /* Reduce zPosition to stop zPosition climbing over UI */
            sushiPiece.zPosition -= 1
        }
        
        firstPiece = sushiTower.first as SushiPiece!
        /* Check character side against sushi piece side (this is our death collision check)*/
        if character.side == firstPiece?.side
        {
            gameOver()
            
            return
        }
        
        /* Increment Health */
        if ( color == UIColor.green )
        {
            health = 1
        }
        else
        {
            health += 0.1
        }
        
        /* Increment Score */
        score += 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
        
        if state != .playing { return }
        
        /* Decrease Health */
        health -= 0.01
        
        /* Has the player ran out of health? */
        if health < 0 { gameOver() }
    }
    
    func addTowerPiece(side: Side)
    {
        /* Add a new sushi piece to the sushi tower */
        
        /* Copy original sushi piece */
        let newPiece = sushiBasePiece.copy() as! SushiPiece
        newPiece.connectChopsticks()
        
        /* Access last piece properties */
        let lastPiece = sushiTower.last
        
        /* Add on top of last piece, default on first piece */
        let lastPosition = lastPiece?.position ?? sushiBasePiece.position
        newPiece.position = lastPosition + CGPoint(x: 0, y: 55)
        
        /* Increment Z to ensure it's on top of the last piece, default on first piece*/
        let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
        newPiece.zPosition = lastZPosition + 1
        
        /* Set side */
        newPiece.side = side
        
        let rand = CGFloat.random(min: 0, max: 1.0)
        if ( rand < 0.05 )
        {
            newPiece.run(SKAction.colorize(with: UIColor.green, colorBlendFactor: 1.0, duration: 0.50))
        }
        
        /* Add sushi to scene */
        self.addChild(newPiece)
        
        /* Add sushi piece to the sushi tower */
        sushiTower.append(newPiece)
    }
    
    func addRandomPieces(total: Int)
    {
        /* Add random sushi pieces to the sushi tower */
        
        for _ in 1...total
        {
            
            /* Need to access last piece properties */
            let lastPiece = sushiTower.last as SushiPiece!
            
            /* Need to ensure we don't create impossible sushi structures */
            if lastPiece?.side != Side.none
            {
                self.addTowerPiece(side: Side.none)
            }
            else
            {
                
                /* Random Number Generator */
                let rand = CGFloat.random(min: 0, max: 1.0)
                
                if rand < 0.45
                {
                    /* 45% Chance of a left piece */
                    self.addTowerPiece(side: .left)
                }
                else if rand < 0.9
                {
                    /* 45% Chance of a right piece */
                    self.addTowerPiece(side: .right)
                }
                else
                {
                    /* 10% Chance of an empty piece */
                    self.addTowerPiece(side: .none)
                }
            }
        }
    }
    
    func gameOver()
    {
        /* Game over! */
        
        state = .gameOver
        
        /* Load the shake action resource */
        let shakeScene:SKAction = SKAction.init(named: "Shake")!
        
        /* Loop through all nodes  */
        for node in self.children
        {
            /* Apply effect each ground node */
            node.run(shakeScene)
        }
        
        /* Turn all the sushi pieces red*/
        for sushiPiece in sushiTower
        {
            sushiPiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        }
        
        /* Make the player turn red */
        character.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        
        self.intro.run(SKAction.move(by: CGVector(dx: 0, dy: -550), duration: 1.5))
        
        titleLabNode.isHidden = false
        
        /* Change play button selection handler */
        playButton.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
    }
}
