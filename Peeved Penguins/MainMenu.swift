import SpriteKit

class MainMenu: SKScene{
    
    // UI variable
    var playButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        
        // Set UI connection
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        
        // Set play button on click
        playButton.selectedHandler = {
            
            self.loadGame()
        }
    }
    
    func loadGame(){
        
        // 1) Grab reference to out Sprite Kit view
        guard let skView = self.view as SKView! else {
            
            print ("Couldn't get SKVeiw")
            return
        }
        
        // 2) Load Game scene
        guard let scene = GameScene.loadLevel(1) else {
            
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        // 3) Ensure correct aspect mode
        scene.scaleMode = .aspectFill
        
        // Show debug
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        // 4) Start Game scene
        skView.presentScene(scene)
        
    }
}
