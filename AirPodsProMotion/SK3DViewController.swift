//
//  SK3DViewController.swift
//
//  I created SK3DViewController with reference to the following repositories and articles.
//  GitHub          : https://github.com/tukuyo/AirPodsPro-Motion-Sampler
//  Article (Qiita) : https://qiita.com/tukutuku_tukuyo/items/ea949ee2dbb499d6e7ca
//

import UIKit
import SceneKit
import CoreMotion
import AVFoundation

class SK3DViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    
    var player: AVAudioPlayer?
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.frame = CGRect(x: self.view.bounds.minX + (self.view.bounds.width / 10),
                            y: self.view.bounds.minY + (self.view.bounds.height / 6),
                            width: self.view.bounds.width, height: self.view.bounds.height)
        view.font = view.font?.withSize(14)
        view.isEditable = false
        view.bringSubviewToFront(view)
        return view
    }()
    
    //AirPods Pro => APP :)
    let APP = CMHeadphoneMotionManager()
    // cube
    var cubeNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        self.title = "Motion Capture"
        
        APP.delegate = self

        SceneSetUp()
        
        playBackMusic()
        
        guard APP.isDeviceMotionAvailable else {
            AlertView.alert(self, "Sorry", "Your device is not supported.")
            return
        }
        var counter: Int = 0
        var stack: Int = 0
        
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            self?.NodeRotate(motion)
            print(motion.attitude.pitch)
            var goodOrBad: Bool = true
            if (motion.attitude.pitch < -0.67) { // 悪姿勢を検知したとき
                counter += 1
            } else {
                counter = 0
            }
            if (counter >= 100) { // 悪姿勢が行って時間以上続いているとき
                goodOrBad = false
                counter = 0
            }
            self?.playSomeSound(goodOrBad)
            if (!goodOrBad) {
                stack += 1
            }
            if (stack >= 1 && stack <= 70) {
                stack += 1
            } else if (stack >= 71) {
                self?.playBackMusic()
                stack = 0
            }
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        APP.stopDeviceMotionUpdates()
    }
    
    func NodeRotate(_ motion: CMDeviceMotion) {
        let data = motion.attitude

        cubeNode.eulerAngles = SCNVector3(-data.pitch, -data.yaw, -data.roll)
    }
    
    func printRotate(_ motion: CMDeviceMotion) {
        print(motion.attitude.pitch)
    }
    
    func playBackMusic() {
        if let soundURL = Bundle.main.url(forResource: "omoide", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                player?.numberOfLoops = -1
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("error...")
            }
        }
    }
    
    func playSomeSound(_ goodOrBad: Bool) {
        if (goodOrBad) {
            //self.textView.text = "good!"
            //view.addSubview(textView)
            print("good posture")
        } else {
            //self.textView.text = "bad.."
            //view.addSubview(textView)
            if let soundURL = Bundle.main.url(forResource: "appear2", withExtension: "wav") {
                do {
                    player = try AVAudioPlayer(contentsOf: soundURL)
                    player?.play()
                } catch {
                    print("error")
                }
            }
            print("bad posture")
        }
    }
}

// SceneKit
extension SK3DViewController {
    
    func SceneSetUp() {
        let scnView = SCNView(frame: self.view.frame)
        scnView.backgroundColor = UIColor.black
        scnView.allowsCameraControl = false
        scnView.showsStatistics = true
        view.addSubview(scnView)

        // Set SCNScene to SCNView
        let scene = SCNScene()
        scnView.scene = scene
        scene.background.contents = UIImage(named: "desert.jpg")

        // Adding a camera to a scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        scene.rootNode.addChildNode(cameraNode)

        // Adding an omnidirectional light source to the scene
        let omniLight = SCNLight()
        omniLight.type = .omni
        let omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(omniLightNode)

        // Adding a light source to your scene that illuminates from all directions.
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.darkGray
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
    
        // Adding a cube(face) to a scene
        let cube:SCNGeometry = SCNPyramid(width: 4, height: 3.7, length: 4)//, chamferRadius: 0.5)
        cube.firstMaterial?.diffuse.contents  = UIColor(red: 196.0 / 255.0, green: 169.0 / 255.0, blue: 133.0 / 255.0, alpha: 1)
        let eye:SCNGeometry = SCNSphere(radius: 0.3)
        let subEye:SCNGeometry = SCNSphere(radius: 0.15)
        let leftEye = SCNNode(geometry: eye)
        let rightEye = SCNNode(geometry: eye)
        leftEye.position = SCNVector3(x: 0.6, y: 1.5, z: 1.3)
        rightEye.position = SCNVector3(x: -0.6, y: 1.5, z: 1.3)
        eye.firstMaterial?.diffuse.contents  = UIColor(red: 241.0 / 255.0, green: 223.0 / 255.0, blue: 100.0 / 255.0, alpha: 1)
        let leftSubEye = SCNNode(geometry: subEye)
        let rightSubEye = SCNNode(geometry: subEye)
        leftSubEye.position = SCNVector3(x: 0.6, y: 1.53, z: 1.5)
        rightSubEye.position = SCNVector3(x: -0.6, y: 1.53, z: 1.5)
        subEye.firstMaterial?.diffuse.contents  = UIColor(red: 58.0 / 255.0, green: 72.0 / 255.0, blue: 97.0 / 255.0, alpha: 1)
        
        let nose:SCNGeometry = SCNSphere(radius: 0.2)
        let noseNode = SCNNode(geometry: nose)
        noseNode.position = SCNVector3(x: 0, y: 1, z: 1.6)
        nose.firstMaterial?.diffuse.contents  = UIColor(red: 209.0 / 255.0, green: 60.0 / 255.0, blue: 77.0 / 255.0, alpha: 1)
        
        let mouth:SCNGeometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.15)
        let mouthNode = SCNNode(geometry: mouth)
        //let mouth:SCNGeometry = SCNBox(width: 1.3, height: 0.2, length: 0.2, chamferRadius: 0.4)
        //let mouthNode = SCNNode(geometry: mouth)
        mouthNode.position = SCNVector3(x: 0, y: 0.5, z: 1.6)
        mouth.firstMaterial?.diffuse.contents  = UIColor(red: 243.0 / 255.0, green: 161.0 / 255.0, blue: 178.0 / 255.0, alpha: 1)
        
        let str = "Posture Detection!"
        let text = SCNText(string: str, extrusionDepth: 0.5)
        text.font = UIFont.systemFont(ofSize: 0.8)
        let m1 = SCNMaterial()
        m1.diffuse.contents = UIColor.blue
        let m2 = SCNMaterial()
        m2.diffuse.contents = UIColor.green
        let m3 = SCNMaterial()
        m3.diffuse.contents = UIColor.systemPink
        text.materials = [m1, m2, m3]
        let textNode = SCNNode(geometry: text)
        let (min, max) = (textNode.boundingBox)
        let textBoundsWidth = (max.x - min.x)
        let textBoundsheight = (max.y - min.y)
        textNode.pivot = SCNMatrix4MakeTranslation(textBoundsWidth/2 + min.x, textBoundsheight/2 + min.y, 0)
        textNode.position = SCNVector3(x: 0, y: 4, z: 1.3)

        cubeNode = SCNNode(geometry: cube)
        cubeNode.addChildNode(leftEye)
        cubeNode.addChildNode(rightEye)
        cubeNode.addChildNode(leftSubEye)
        cubeNode.addChildNode(rightSubEye)
        cubeNode.addChildNode(noseNode)
        cubeNode.addChildNode(mouthNode)
        cubeNode.addChildNode(textNode)
        cubeNode.position = SCNVector3(x: 0, y: -0.7, z: 0.2)
        scene.rootNode.addChildNode(cubeNode)
    }
}
