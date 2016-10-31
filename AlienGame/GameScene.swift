//
//  GameScene.swift
//  BingBang
//
//  Created by Wood, Ben on 12/14/15.
//  Copyright (c) 2015 Wood, Benjamin. All rights reserved.
//

import SpriteKit
import Social
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
 
    // Needed to tell if contact between physics bodies
    struct PhysicsCatagory {
        static let enemies : UInt32 = 1
        static let player: UInt32 = 2
        
    }
    
    var player = SKSpriteNode (imageNamed:"Spaceman1.gif")
    var scoreLabel = UILabel()
    var playing = false
    var timerCount = 0
    var timer = Timer()
    var Highscore = Int()
    var enemyTimer = Timer()
    var bottomEnemyTimer = Timer()
    var leftEnemyTimer = Timer()
    var rightEnemyTimer = Timer()
    var wallBottom = SKSpriteNode(imageNamed:"Black.png")
    var highScoreLabel = UILabel()
    var buttonContainsTouch = false
    var screenshot = UIImage()
    var pause = false
    var restartBTN = SKSpriteNode()
    var shareBTN = SKSpriteNode()
    var gameVCDelegate : GameViewControllerDelegate?
    var audioPlayer = AVAudioPlayer()
    var boundryCount = 0
    var soundOn = true
    var soundTimer = Timer()
  
    
    func restartScene (){
        self.removeAllChildren()
        highScoreLabel.isHidden = true
        if pause == false {
        
        timerCount = 0
        restartBTN.removeFromParent()
        scoreLabel.isHidden = false
        createScene()
        
        } else {
        
        restartBTN.removeFromParent()
        scoreLabel.isHidden = false
        createScene()
        pause = false
           
            
        }
        
        
    }
    
    func createScene (){
        
        self.addChild(player)
        var highScoreDefault = UserDefaults.standard
        if(highScoreDefault.value(forKey: "Highscore") != nil){
            
            Highscore =  highScoreDefault.value(forKey: "Highscore") as! NSInteger
            
        } else {
            
            Highscore = 0
        }
       
        
        scoreLabel.frame = CGRect (x: 0,y: 0,width: self.size.width, height: self.size.height / 2)
        scoreLabel.center =  CGPoint(x: view!.frame.size.width / 2, y: view!.frame.size.height / 7)
        scoreLabel.textAlignment = NSTextAlignment.center
        scoreLabel.text = "\(timerCount)"
        scoreLabel.font = UIFont (name: "Futura-CondensedExtraBold", size: 135)
        scoreLabel.textColor = UIColor.gray
        self.view!.addSubview(scoreLabel)
        scoreLabel.sendSubview(toBack: self.view!)
        
        physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector (dx: 0, dy: -5)
       
        playing = true
        
        player.position = CGPoint(x: self.size.width/2, y: self.size.height + player.size.height)
        
        player.size = CGSize(width: self.size.width/12, height: self.size.height / 8)
        player.physicsBody = SKPhysicsBody (rectangleOf: CGSize(width: player.size.width - 20, height: player.size.height - 20))
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCatagory.player
        player.physicsBody?.contactTestBitMask = PhysicsCatagory.enemies
        
        
        enemyTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.spawnEnemies), userInfo: nil, repeats: true)
    
        bottomEnemyTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.spawnBottomEnemies), userInfo: nil, repeats: true)
        
        leftEnemyTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.spawnLeftEnemies), userInfo: nil, repeats: true)
        
        rightEnemyTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.spawnRightEnemies), userInfo: nil, repeats: true)
        
        self.backgroundColor = UIColor.black
        
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.scoring), userInfo: nil, repeats: true)
        
        
        createStarBackground()
        
        
        highScoreLabel = UILabel(frame: CGRect (x: 0,y: 0,width: self.size.width, height: self.size.height / 2))
        highScoreLabel.center =  CGPoint(x: view!.frame.size.width / 2, y: view!.frame.size.height / 2 + view!.frame.size.height / 4)
        highScoreLabel.textAlignment = NSTextAlignment.center
        highScoreLabel.text = "Highscore = \(Highscore)"
        highScoreLabel.font = UIFont (name: "Futura-CondensedExtraBold", size: 35)
        highScoreLabel.textColor = UIColor.gray
        self.view!.addSubview(highScoreLabel)
        highScoreLabel.isHidden = true
        self.gameVCDelegate?.setShareButtonHidden(true)

    }
    
    func createStarBackground(){
        wallBottom = SKSpriteNode(imageNamed:"Black.png")
        wallBottom.size = CGSize(width: self.frame.width * 10, height: 1)
        wallBottom.position = CGPoint (x: self.frame.width / 2,y: 0 - player.size.height)
        wallBottom.physicsBody = SKPhysicsBody (rectangleOf: CGSize(width: view!.frame.size.width, height: 1))
        wallBottom.physicsBody?.affectedByGravity = false
        wallBottom.physicsBody?.categoryBitMask =  PhysicsCatagory.enemies
        wallBottom.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        wallBottom.physicsBody?.isDynamic = false
        self.addChild(wallBottom)
        wallBottom.addChild(SKEmitterNode (fileNamed: "background")!)
    }
    
    func createTopBoundry() {
        
        let  wallTop = SKSpriteNode(imageNamed:"Black.png")
        wallTop.size = CGSize(width: self.frame.width * 10, height: 1)
        wallTop.position = CGPoint (x: self.frame.width / 2,y: self.frame.height + player.size.height)
        wallTop.physicsBody = SKPhysicsBody (rectangleOf: CGSize(width: self.frame.width * 10, height: 1))
        wallTop.physicsBody?.affectedByGravity = false
        wallTop.physicsBody?.categoryBitMask =  PhysicsCatagory.enemies
        wallTop.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        wallTop.physicsBody?.isDynamic = false
        self.addChild(wallTop)
    }
    
    override func didMove(to view: SKView) {
        
        
        createScene()
        createBTN()
        scoreLabel.isHidden = true
        highScoreLabel.isHidden = true
        
       
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.pauseGameScene), name: NSNotification.Name(rawValue: "pause"), object: nil)
        
        let myFilePathString = Bundle.main.path(forResource: "jump", ofType: "mp3")
        
        if let myFilePathString = myFilePathString {
            
            let myFilePathURL = URL(fileURLWithPath: myFilePathString)
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: myFilePathURL)
                
            } catch {
                print(error)
            }
        }
        
    }
    
    func scoring (){
        timerCount += 1
        scoreLabel.text = "\(timerCount)"
     
    }
    
    
    
    
    
    
    func createBTN(){
        restartBTN = SKSpriteNode(imageNamed: "newStartButton.png")
        restartBTN.size = CGSize(width: self.frame.width / 2.5, height: self.frame.height / 7)
        restartBTN.position = CGPoint (x: self.frame.width / 2, y: self.frame.height / 2 + (restartBTN.size.height/2))
        restartBTN.zPosition = 6
        
        shareBTN = SKSpriteNode(imageNamed: "newPodium.png")
        shareBTN.size = CGSize(width: self.frame.width / 2.5, height: self.frame.height / 7)
        shareBTN.position = CGPoint (x: self.frame.width / 2, y: self.frame.height / 2 - (shareBTN.size.height/2))
        shareBTN.zPosition = 6
        if pause == true {
            restartBTN.texture = SKTexture(imageNamed: "ContinueButton.png")
        }
        else {
           self.addChild(shareBTN)
        }
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.removeAllActions()
        enemyTimer.invalidate()
        bottomEnemyTimer.invalidate()
        leftEnemyTimer.invalidate()
        rightEnemyTimer.invalidate()
        timer.invalidate()
        soundTimer.invalidate()

        playing = false
        self.addChild(restartBTN)
        
        highScoreLabel.isHidden = false
        boundryCount = 0
        
        player.texture = SKTexture(imageNamed: "Spaceman1.gif")
       
        if Highscore >= 10 {
            player.texture = SKTexture(imageNamed: "SpacemanJunior.png")
            player.size = CGSize(width: self.size.width/12, height: self.size.height / 8)
        }
        
        if Highscore >= 20 {
            player.texture = SKTexture(imageNamed: "SpacemanCowboy.png")
            
        }
        if Highscore >= 25 {
            player.texture = SKTexture(imageNamed: "SpacemanWizard.png")
            player.size = CGSize(width: self.size.width/12, height: self.size.height / 8)
        }

        if Highscore >= 35 {
            player.texture = SKTexture(imageNamed: "SpacemanGoober.png")
            
        }

        if Highscore >= 45 {
            player.texture = SKTexture(imageNamed: "SpacemanNorseman.png")
            player.size = CGSize(width: self.size.width/12, height: self.size.height / 8)
        }

        if Highscore >= 50 {
            player.texture = SKTexture(imageNamed: "CrownSpaceman.png")
            player.size = CGSize(width: self.size.width/12, height: self.size.height / 8)
        }
        
         self.gameVCDelegate?.setShareButtonHidden(false)
        
    }
    

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == PhysicsCatagory.enemies) && (secondBody.categoryBitMask == PhysicsCatagory.player) || (firstBody.categoryBitMask == PhysicsCatagory.player ) && (secondBody.categoryBitMask == PhysicsCatagory.enemies)){
            collisionWithPerson(firstBody.node as! SKSpriteNode, enemies: secondBody.node as! SKSpriteNode)
            
        }
        
        
    }
    
    func collisionWithPerson (_ player: SKSpriteNode, enemies: SKSpriteNode) {
        let ScoreDefault = UserDefaults.standard
        ScoreDefault.setValue(timerCount, forKey: "Score")
        ScoreDefault.synchronize()
        
        if (timerCount > Highscore) {
            
            let highScoreDefault = UserDefaults.standard
            highScoreDefault.setValue(timerCount, forKey: "Highscore")
            Highscore = timerCount
            highScoreLabel.text = "Highscore = \(Highscore)"
            
            
        }
    
        createBTN()
        self.removeAllActions()
        
    }
    
    
    func spawnEnemies () {
       
        let enemies = SKSpriteNode (imageNamed: "a2.png")
        enemies.size = CGSize(width: self.size.width / 7.5, height: self.size.height / 4.5)
        let MINVALUE = self.size.width / 8
        let MAXVALUE = self.size.width - 20
        let SPAWNPOINT = UInt32(MAXVALUE - MINVALUE)
        enemies.position = CGPoint(x: CGFloat(arc4random_uniform(SPAWNPOINT)), y: self.size.height - 20)
        
        enemies.physicsBody = SKPhysicsBody (circleOfRadius: enemies.size.width/5)
        enemies.physicsBody?.affectedByGravity = false
        enemies.physicsBody?.categoryBitMask =  PhysicsCatagory.enemies
        enemies.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        enemies.physicsBody?.isDynamic = true
      
      
        let action = SKAction.moveTo(y: -60, duration: 6)
        let actionDone = SKAction.removeFromParent()
        enemies.run(SKAction.sequence([action,actionDone]))
        
        self.addChild(enemies)
        

    }
    
    func spawnBottomEnemies () {
        
        let bottomEnemies = SKSpriteNode (imageNamed: "a2.png")
        bottomEnemies.size = CGSize(width: self.size.width / 7.5, height: self.size.height / 4.5)
        let MINVALUE = self.size.width / 8
        let MAXVALUE = self.size.width - 20
        let SPAWNPOINT = UInt32(MAXVALUE - MINVALUE)
        bottomEnemies.position = CGPoint(x: CGFloat(arc4random_uniform(SPAWNPOINT)), y: -30)
        bottomEnemies.physicsBody = SKPhysicsBody (circleOfRadius: bottomEnemies.size.width/5)
        bottomEnemies.physicsBody?.affectedByGravity = false
        bottomEnemies.physicsBody?.categoryBitMask =  PhysicsCatagory.enemies
        bottomEnemies.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        bottomEnemies.physicsBody?.isDynamic = true

        let action = SKAction.moveTo(y: self.size.height - 20, duration: 6)
        let actionDone = SKAction.removeFromParent()
        bottomEnemies.run(SKAction.sequence([action,actionDone]))
        self.addChild(bottomEnemies)
    }

    func spawnLeftEnemies () {
        
        let leftEnemies = SKSpriteNode (imageNamed: "a2.png")
        leftEnemies.size = CGSize(width: self.size.width / 9, height: self.size.height / 5.5)
        let MINVALUE = CGFloat(0)
        let MAXVALUE = self.size.height
        let SPAWNPOINT = UInt32(MAXVALUE - MINVALUE)
        leftEnemies.position = CGPoint(x: 0, y: CGFloat(arc4random_uniform(SPAWNPOINT)))
        
        leftEnemies.physicsBody = SKPhysicsBody (circleOfRadius: leftEnemies.size.width/5)
        leftEnemies.physicsBody?.affectedByGravity = false
        leftEnemies.physicsBody?.categoryBitMask =  PhysicsCatagory.enemies
        leftEnemies.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        leftEnemies.physicsBody?.isDynamic = true
        
        let action = SKAction.moveTo(x: self.size.width + 10, duration: 10)
        let actionDone = SKAction.removeFromParent()
        leftEnemies.run(SKAction.sequence([action,actionDone]))
        
        self.addChild(leftEnemies)
    }
    
    func spawnRightEnemies () {
        
        let rightEnemies = SKSpriteNode (imageNamed: "a2.png")
        rightEnemies.size = CGSize(width: self.size.width / 9, height: self.size.height / 5.5)
        let MINVALUE = CGFloat(0)
        let MAXVALUE = self.size.height
        let SPAWNPOINT = UInt32(MAXVALUE - MINVALUE)
        rightEnemies.position = CGPoint(x: self.size.width + 20, y: CGFloat(arc4random_uniform(SPAWNPOINT)))
        
        rightEnemies.physicsBody = SKPhysicsBody (circleOfRadius: rightEnemies.size.width/5)
        rightEnemies.physicsBody?.affectedByGravity = false
        rightEnemies.physicsBody?.categoryBitMask =  PhysicsCatagory.enemies
        rightEnemies.physicsBody?.contactTestBitMask = PhysicsCatagory.player
        rightEnemies.physicsBody?.isDynamic = true
        
        let action = SKAction.moveTo(x: -10, duration: 10)
        let actionDone = SKAction.removeFromParent()
        rightEnemies.run(SKAction.sequence([action,actionDone]))
        self.addChild(rightEnemies)
    }
    
   
    func playMusic (){
        if soundOn {
        audioPlayer.play()
        audioPlayer.volume = 0.25
        audioPlayer.rate = 2.0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        for touch in touches {
           
            let location = touch.location(in: self)
            
            if (playing == true) {
                if player.intersects(self) {
            player.physicsBody!.velocity = CGVector (dx: 0,dy: 10)
            self.physicsWorld.gravity = CGVector (dx: 0, dy: 1.75)
            player.texture = SKTexture(imageNamed: "Spaceman.png")
            highScoreLabel.isHidden = true
            soundTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(GameScene.playMusic), userInfo: nil, repeats: true)
                
            
                    if boundryCount == 0 {
                        createTopBoundry()
                        boundryCount += 1
                    }
                }
            
            }
            
            if (restartBTN.contains(location) && playing == false){
                
                buttonContainsTouch = true
                
            }

        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (playing == true) {
            if (player.intersects(self) ){
            let location = touch.location(in: self)
                    player.position.x = location.x
        
            }
            else {
               createBTN()

                }}
           
            
            
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
             let location = touch.location(in: self)
       
             if (playing == true) {
                    if (player.intersects(self)) {
                        player.physicsBody!.velocity = CGVector (dx: 0,dy: -20)
                        self.physicsWorld.gravity = CGVector (dx: 0, dy: -1.75)
                        player.texture = SKTexture(imageNamed: "Spaceman1.gif")
                        soundTimer.invalidate()
                    }
                
                
             }
            
            if (restartBTN.contains(location) && playing == false && buttonContainsTouch == true){
                
                restartScene()
                buttonContainsTouch = false
                
            }
            
            else if (shareBTN.contains(location) && playing == false) {
            
                self.gameVCDelegate!.ShareFunction(shareBTN)
            }
            
            
        }
           
}


    
    func captureScreen() -> UIImage {
        
        highScoreLabel.isHidden = true
        let socialImage = "highScoreImage.png"
        let image = UIImage(named: socialImage)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: view!.frame.size.width, height: view!.frame.size.height)
        view!.addSubview(imageView)
        
        let socialLabel = UILabel(frame: CGRect (x: 0,y: 0,width: self.size.width, height: self.size.height / 2))
        socialLabel.frame = CGRect (x: 0,y: 0,width: self.size.width, height: self.size.height / 2)
        socialLabel.center =  CGPoint(x: view!.frame.size.width / 2, y: view!.frame.size.height / 3.75)
        socialLabel.textAlignment = NSTextAlignment.center
        socialLabel.text = "\(Highscore)"
        socialLabel.font = UIFont (name: "Futura-CondensedExtraBold", size: 150)
        socialLabel.textColor = UIColor.black
        self.view!.addSubview(socialLabel)
        
        var window: UIWindow? = UIApplication.shared.keyWindow
        window = UIApplication.shared.windows[0] as? UIWindow
        UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.isOpaque, 0.0)
        window!.layer.render(in: UIGraphicsGetCurrentContext()!)
        screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        imageView.removeFromSuperview()
        socialLabel.removeFromSuperview()
        return screenshot
    }
    
    func pauseGameScene() {
       
        pause = true
        highScoreLabel.isHidden = true
        createBTN()
        
        
    }
    

    
}

