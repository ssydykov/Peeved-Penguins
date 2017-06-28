import SpriteKit

class Penguin: SKSpriteNode{
    
    init(){
        
        // Making texture from image, color and size
        let texture = SKTexture(imageNamed: "flyingpenguin")
        let color = UIColor.clear
        let size = texture.size()
        
        // Call the designated initializer
        super.init(texture: texture, color: color, size: size)
        
        // Set physics properties
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = 1
        physicsBody?.friction = 0.6
        physicsBody?.mass = 0.5
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init() has not been implemented")
    }
}
