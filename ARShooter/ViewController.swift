//
//  ViewController.swift
//  ARShooter
//
//  Created by paw on 12.02.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreLabelLabel: UILabel!
    var tempScore = 0{
        didSet{
            DispatchQueue.main.async { [unowned self] in
                scoreLabel.text = "\(tempScore)"
            }
        }
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerLabelLabel: UILabel!
    var timer = 60{
        didSet{
            timerLabel.text = "\(timer)"
        }
    }
    

    @IBAction func onBananaTapped(_ sender: Any) {
        fireMissile(type: "banana")
    }
    @IBAction func onAxeTapped(_ sender: Any) {
        fireMissile(type: "axe")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        
//        // Set the scene to the view
//        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
        timerLabelLabel.layer.cornerRadius = 10
        scoreLabelLabel.layer.cornerRadius = 10
        timerLabel.layer.cornerRadius = timerLabel.bounds.height/2
        scoreLabel.layer.cornerRadius = scoreLabel.bounds.height/2
        addTargetNodes()
//        addBox()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if AppDelegate.score < self.tempScore {
            AppDelegate.score = self.tempScore
        }
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
            
//             print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
            
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue
                || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue {
                
                if (contact.nodeA.name! == "Box" || contact.nodeB.name! == "Box") {
                    tempScore+=5
                }else{
                    tempScore+=1
                }
                
                DispatchQueue.main.async {
                    contact.nodeA.removeFromParentNode()
                    contact.nodeB.removeFromParentNode()
                    //self.scoreLabel.text = String(self.score)
                }
            }
        playSound(sound: "explosion", format: "wav")
        let explode = SCNParticleSystem(named: "Explode", inDirectory: nil)
        contact.nodeB.addParticleSystem(explode!)
        }
    func playBackgroundMusic(){
            let audioNode = SCNNode()
            let audioSource = SCNAudioSource(fileNamed: "overtake.mp3")!
            let audioPlayer = SCNAudioPlayer(source: audioSource)
            
            audioNode.addAudioPlayer(audioPlayer)
            
            let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
            audioNode.runAction(play)
            sceneView.scene.rootNode.addChildNode(audioNode)
        }
    
    func addTargetNodes(){
            for index in 1...30 {
                
                let node = SCNNode()
                
                if (index > 9) && (index % 10 == 0) {
                    let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
                    
                    node.geometry = box
                    node.name = "Box"
                }else{
                    let box = SCNSphere(radius: 1)//(width: 1, height: 1, length: 1, chamferRadius: 0)
                    
                    node.geometry = box
                    node.name = "bath"
                }
                let colors = [UIColor.green, // front
                    UIColor.red, // right
                    UIColor.blue, // back
                    UIColor.yellow, // left
                    UIColor.purple, // top
                    UIColor.gray] // bottom
                
                let sideMaterials = colors.map { color -> SCNMaterial in
                    let material = SCNMaterial()
                    material.diffuse.contents = color
                    material.locksAmbientWithDiffuse = true
                    return material
                }
                node.geometry?.materials = sideMaterials
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                node.physicsBody?.isAffectedByGravity = false
                
                //place randomly, within thresholds
                node.position = SCNVector3(randomFloat(min: -10, max: 10),randomFloat(min: -4, max: 5),randomFloat(min: -10, max: 10))
                
                //rotate
                let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
                let forever = SCNAction.repeatForever(action)
                node.runAction(forever)
                
                node.physicsBody? .categoryBitMask = CollisionCategory.targetCategory.rawValue
                node.physicsBody? .contactTestBitMask = CollisionCategory.missileCategory.rawValue
                //add to scene
                sceneView.scene.rootNode.addChildNode(node)
            }
        playBackgroundMusic()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] (tim) in
            if timer > 0{
                timer-=1
            }else{
                tim.invalidate()
                dismiss(animated: true, completion: nil)
            }
        }
        }
    
    
    func randomFloat (min: Float, max: Float) -> Float {
        return (Float (arc4random ()) / 4294967296) * (max - min) + min
    }
    
    func addBox() {
            let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
            
            let boxNode = SCNNode()
            boxNode.geometry = box
            boxNode.position = SCNVector3(0, 0, -0.2)
            
            let colors = [UIColor.green, // front
                UIColor.red, // right
                UIColor.blue, // back
                UIColor.yellow, // left
                UIColor.purple, // top
                UIColor.gray] // bottom
            
            let sideMaterials = colors.map { color -> SCNMaterial in
                let material = SCNMaterial()
                material.diffuse.contents = color
                material.locksAmbientWithDiffuse = true
                return material
            }
            boxNode.geometry?.materials = sideMaterials
            sceneView.scene.rootNode.addChildNode(boxNode)
        }
    
    
    func fireMissile(type : String){ //эта строка показывает, что мы ожидаем строковый параметр с именем type, который снова используется для указания «топора» или «банана»:
        var node = SCNNode()
        node = createMissile(type: type) //Он получает позицию и направление пользователя, используя функцию, которую мы написали ранее
        let (direction, position) = self.getUserVector() //Это использует эту позицию в качестве начальной позиции ракеты, то есть она будет выходить с точки зрения пользователя в приложении при запуске
        node.position = position
        var nodeDirection = SCNVector3()
        switch type {
        case "banana":
            nodeDirection  = SCNVector3(direction.x*4,direction.y*4,direction.z*4)//Эта линия устанавливает направление, в котором пойдет ракета '* 4' используется для увеличения скорости ракеты - вы можете изменить это значение по мере необходимости
            node.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.1,0,0), asImpulse: true)//Эта линия прикладывает силу к оси x узла - с эффектом вращения узла, просто для аффекта
            playSound(sound: "monkey", format: "mp3")
        case "axe":
            nodeDirection  = SCNVector3(direction.x*4,direction.y*4,direction.z*4)
            node.physicsBody?.applyForce(SCNVector3(direction.x,direction.y,direction.z), at: SCNVector3(0,0,0.1), asImpulse: true)
            playSound(sound: "rooster", format: "mp3")
        default:
            nodeDirection = direction
        }
        
        node.physicsBody?.applyForce(nodeDirection , asImpulse: true) //строка фактически «запускает» ракетный узел, прикладывая силу в указанном нами направлении
        sceneView.scene.rootNode.addChildNode(node) //Затем, наконец, узел добавляется в сцену, чтобы пользователь мог видеть
    }
    
    func createMissile(type : String)->SCNNode{ //SCNNode в основном «объект» , который появляется в сцене для игрока , чтобы видеть, и это одна из самых важных классов , которые вы будете использовать в создании AR игр
        var node = SCNNode()
        
        //используя оператор case, чтобы разрешить изменение масштаба и поворота
        switch type {
        case "banana":
            let scene = SCNScene(named: "art.scnassets/banana.dae")
            node = (scene?.rootNode.childNode(withName: "Cube_001", recursively: true)!)!//Это берет основной узел из файла .dae и назначает его нашему экземпляру SCNNode, называемому узлом. «Cube_001» - это имя этого узла
            node.scale = SCNVector3(0.1,0.1,0.1)//Эта линия меняет размер модели - многие модели огромны, когда вы их получаете. Мы изменяем размер с помощью SCNVector3 и предоставляем значения для x, y и z, здесь значение 0,2. Это в основном приводит к изменению размера модели до 20% от исходного размера
            node.name = "banana" //Затем мы даем SCNNode имя «банан». Это будет использоваться позже, чтобы помочь нам программно определить, какие объекты находятся в сцене
        case "axe":
            let scene = SCNScene(named: "art.scnassets/axe.dae")
            node = (scene?.rootNode.childNode(withName: "axe", recursively: true)!)!
            node.scale = SCNVector3(0.2,0.2,0.2)
            node.name = "bathtub"
        default:
            node = SCNNode()
        }
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        
        node.physicsBody?.categoryBitMask = CollisionCategory.missileCategory.rawValue
        node.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        
        return node
    }
    
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            // 4x4  transform matrix describing camera in world space
            let mat = SCNMatrix4(frame.camera.transform)
            // orientation of camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
            // location of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    var player: AVAudioPlayer?
       
       func playSound(sound : String, format: String) {
           guard let url = Bundle.main.url(forResource: sound, withExtension: format) else { return }
           do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
               try AVAudioSession.sharedInstance().setActive(true)

               player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
               
               guard let player = player else { return }
               player.play()
           } catch let error {
               print(error.localizedDescription)
           }
       }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


struct CollisionCategory: OptionSet {
   let rawValue: Int
   static let missileCategory = CollisionCategory (rawValue: 1 << 0)
   static let targetCategory = CollisionCategory (rawValue: 1 << 1)
}
