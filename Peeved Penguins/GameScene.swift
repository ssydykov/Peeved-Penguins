//
//  GameScene.swift
//  Peeved Penguins
//
//  Created by Saken Sydykov on 26.06.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Sprite nodes
    var catapult: SKSpriteNode!
    var catapultArm: SKSpriteNode!
    var cameraNode: SKCameraNode!
    var cameraTarget: SKSpriteNode?
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    var restartButton: MSButtonNode!
    
    // Variables
    var currentLevel: Int! = 1
    
    // Physics variables
    var touchJoint: SKPhysicsJointSpring?
    var penguinJoint: SKPhysicsJointPin?
    
    override func didMove(to view: SKView) {
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        // Set connetions
        catapult = childNode(withName: "catapult") as! SKSpriteNode
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        restartButton = childNode(withName: "//restartButton") as! MSButtonNode
        cantileverNode = childNode(withName: "cantileverNode") as! SKSpriteNode
        touchNode = childNode(withName: "touchNode") as! SKSpriteNode
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        
        restartButton.selectedHandler = {
            
            guard let scene = GameScene.loadLevel(self.currentLevel) else {
                
                print ("Level is missing?")
                return
            }
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
        
        setupCatapult()
    }
    
    func setupCatapult(){
        
        var pinLocation = catapult.position
        pinLocation.x += -10
        pinLocation.y += -70
        
        let catapultJoint = SKPhysicsJointPin.joint(
            withBodyA: catapult.physicsBody!,
            bodyB: catapultArm.physicsBody!,
            anchor: pinLocation)
        
        physicsWorld.add(catapultJoint)
        
        // Catapult arm and cantilever joint
        var anchorAPosition = catapultArm.position
        anchorAPosition.y += 50
        anchorAPosition.x += 0
        let catapultSpringJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: anchorAPosition, anchorB: cantileverNode.position)
        physicsWorld.add(catapultSpringJoint)
        catapultSpringJoint.frequency = 6
        catapultSpringJoint.damping = 0.5
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        /* Check if either physics bodies was a seal */
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            
            /* Was the collision more than a gentle nudge? */
            if contact.collisionImpulse > 2.0 {
                /* Kill Seal */
                if contactA.categoryBitMask == 2 { removeSeal(node: nodeA) }
                if contactB.categoryBitMask == 2 { removeSeal(node: nodeB) }
            }
        }
    }
    
    func removeSeal(node: SKNode) {
        /* Seal death*/
        
        /* Play SFX */
        let sound = SKAction.playSoundFileNamed("sfx_seal.caf", waitForCompletion: false)
        self.run(sound)
        
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "Poof")!
        
        /* Position particles at the Seal node
         If you've moved Seal to an sks, this will need to be
         node.convert(node.position, to: self), not node.position */
        particles.position = node.position
        
        /* Add particles to scene */
        addChild(particles)
        let wait = SKAction.wait(forDuration: 5)
        let removeParticles = SKAction.removeFromParent()
        let seq = SKAction.sequence([wait, removeParticles])
        particles.run(seq)
        
        /* Create our hero death action */
        let sealDeath = SKAction.run({
            /* Remove seal node from scene */
            node.removeFromParent()
        })
        self.run(sealDeath)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        if nodeAtPoint.name == "catapultArm" {  // If the touched node is named "catapultArm" do...
            touchNode.position = location
            touchJoint = SKPhysicsJointSpring.joint(
                withBodyA: touchNode.physicsBody!,
                bodyB: catapultArm.physicsBody!,
                anchorA: location, anchorB: location)
            
            let penguin = Penguin()
            addChild(penguin)
            penguin.position.x += catapultArm.position.x + 20
            penguin.position.y += catapultArm.position.y + 50
            penguin.physicsBody?.usesPreciseCollisionDetection = true
            penguinJoint = SKPhysicsJointPin.joint(
                withBodyA: catapultArm.physicsBody!,
                bodyB: penguin.physicsBody!,
                anchor: penguin.position)
            
            physicsWorld.add(penguinJoint!)
            cameraTarget = penguin
            physicsWorld.add(touchJoint!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        touchNode.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
        
        // Check for a touchJoint then remove it.
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
        // Check for a penguin joint then remove it.
        if let penguinJoint = penguinJoint {
            physicsWorld.remove(penguinJoint)
        }
        // Check if there is a penuin assigned to the cameraTarget
        guard let penguin = cameraTarget else {
            return
        }
        // Generate a vector and a force based on the angle of the arm.
        let force: CGFloat = 350
        let r = catapultArm.zRotation
        let dx = cos(r) * force
        let dy = sin(r) * force
        // Apply an impulse at the vector. 
        let v = CGVector(dx: dx, dy: dy)
        penguin.physicsBody?.applyImpulse(v)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        moveCamera()
    }
    
    // Move camera method
    func moveCamera(){
        
        guard let cameraTarget = cameraTarget else {
            
            return
        }
        
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
    
    // Class method for loading levels
    class func loadLevel(_ levelNumber: Int) -> GameScene? {
        
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
        
            return nil
        }
        
        scene.scaleMode = .aspectFill
        return scene
    }
}

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    
    return min(max(value, lower), upper)
}


