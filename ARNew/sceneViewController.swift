//
//  scenViewController.swift
//  ARNew
//
//  Created by Hossein Payami on 2/22/1398 AP.
//  Copyright © 1398 Hossein Payami. All rights reserved.
//
import AVFoundation
import UIKit
import ARKit
import SpriteKit
import Foundation
class sceneViewController: UIViewController,ARSCNViewDelegate,ARSessionDelegate  {




    



    //MARK: Declaration

    let configuration = ARWorldTrackingConfiguration()
    let augmentedRealitySession = ARSession()



    //MARK: Declaration VideoNode,VideoType,VideoFilter
    var planeNode = SCNNode()
    var videoNode : SKVideoNode!
    var videoFile : String = ""
    var videoProcessingFunction : String = ""

    var greenScreenFiles : [String] = [String]()
    var CompositeVideoFiles : [String] = [String]()

    var videoFilePicker : [String] = [String]()
    var videoProcessingFuncPicker : [String] = [String]()



    let arView: ARSCNView = {
        let view = ARSCNView()
        return view
    }()



    lazy var resetbutton: UIButton = {

        var button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        button.setTitle("Reset", for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleResetButtonTapped), for: UIControl.Event.touchUpInside)
        button.layer.zPosition = 1
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        arView.delegate = self
        let scn = SCNScene(named: "art.scnassets/scen.scn")!
        arView.scene = scn
        view.addSubview(arView)
        view.addSubview(resetbutton)
        initializingControlls()
        arView.session.run(configuration, options: [])
        arView.debugOptions = [debug(.Both)]
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configuration.planeDetection = .horizontal
        arView.session.run(configuration)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }





    lazy var gesture: UIPinchGestureRecognizer = {

        var gest = UIPinchGestureRecognizer(target: self, action:  #selector(scalePiece))

        return gest
    }()


    /// Scales An SCNNode
    ///
    /// - Parameter gesture: UIPinchGestureRecognizer
    @objc func scalePiece(_ gesture  : UIPinchGestureRecognizer) {


        

        }


    //MARK: Reset Scene

    @objc func handleResetButtonTapped(){
        resetScene()
    }

    func resetScene(){

        arView.session.pause()
        arView.session.run(configuration, options: [.removeExistingAnchors,.resetTracking])
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {


        let videoURL : URL = Bundle.main.url(forResource: "simple", withExtension: "mp4")!
        let url =  videoURL
        let asset = AVAsset(url: url)
        let filter = colorCubeFilterForChromaKey(hueAngle: 120)

        let item = AVPlayerItem(asset: asset)

        let player = AVPlayer(playerItem: item)

        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.play()



        // create a video scene
        let videoScene = SKScene(size: CGSize(width: 200, height: 300))

        // make video the same size as the scene, but could be smaller
        videoNode.size   = CGSize(width: videoScene.size.width, height: videoScene.size.height)

        // center video inside the scene
        videoNode.position = CGPoint(x: videoScene.size.width/2 , y: videoScene.size.height/2 )

        // invert our video so it does not look upside down
        videoNode.yScale = -1.0

        // add video Node to effect Node AND apply effect to effect Node
        let effectNode = SKEffectNode()

        effectNode.addChild(videoNode)
        effectNode.filter = filter

        // add the video to our scene
        videoScene.addChild(effectNode)

        // clear background color of the scene. By default it is set to black
        videoScene.backgroundColor = .clear

        // create a plane with some real world height and width
        // NOTE: plane is just a wireframe. Like a human skeleton. It's just the shape.
        // unit of measurements is Meters
        let plane = SCNPlane(width: 0.50, height: 1.0)

        // set the first materials content to be our video scene
        // contents material could be color, image, video (in this case), etc.
        // NOTE: Material is what covers the plane. Like skin on a skeleton. It gives it the look.
        plane.firstMaterial?.diffuse.contents = videoScene

        // if you want to be able to go behind the video and see it from behind
        plane.firstMaterial?.isDoubleSided = true

        // create a node out of the plane
      //  let planeNode = SCNNode(geometry: plane)
        planeNode.geometry = plane

        // place the video 3 meters away
        planeNode.position = SCNVector3(0,0,-1.25)

        // since the created node will be vertical, rotate it along the x axis to have it be horizontal or parallel to our detected image
        // planeNode.eulerAngles.x = -Float.pi / 2

        // finally add the plane node (which contains the video node) to the added node
        self.arView.scene.rootNode.addChildNode(planeNode)


    }






    func initializingControlls(){

        view.backgroundColor = .clear
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        arView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true


        resetbutton.translatesAutoresizingMaskIntoConstraints = false

        resetbutton.topAnchor.constraint(equalTo: view.topAnchor).isActive = false
        resetbutton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        resetbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        resetbutton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

    }


    func RGBtoHSV(r : Float, g : Float, b : Float) -> (h : Float, s : Float, v : Float) {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var v : CGFloat = 0
        let col = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        col.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
        return (Float(h), Float(s), Float(v))
    }

    func colorCubeFilterForChromaKey(hueAngle: Float) -> CIFilter {

        // minHueAngle: Sets the lower limit for the color to filter out. Applies to HSV color.
        // maxHueAngle: Sets the upper limit for the color to filter out. Applies to HSV color.
        // hueRange: Sets the range between lower and upper limits. Applies to HSV color.
        //
        // NOTE: yellow, for example, is a shade of green. So, make sure hueRange does not include colors like yellow.
        //
        // color range explained here: https://en.wikibooks.org/wiki/Color_Models:_RGB,_HSV,_HSL

        let hueRange: Float = 80 // degrees size pie shape that we want to replace
        let minHueAngle: Float = (hueAngle - hueRange/2.0) / 360
        let maxHueAngle: Float = (hueAngle + hueRange/2.0) / 360

        let size = 64
        var cubeData = [Float](repeating: 0, count: size * size * size * 4)
        var rgb: [Float] = [0, 0, 0]
        var hsv: (h : Float, s : Float, v : Float)
        var offset = 0

        for z in 0 ..< size {
            rgb[2] = Float(z) / Float(size) // blue value
            for y in 0 ..< size {
                rgb[1] = Float(y) / Float(size) // green value
                for x in 0 ..< size {

                    rgb[0] = Float(x) / Float(size) // red value
                    hsv = RGBtoHSV(r: rgb[0], g: rgb[1], b: rgb[2])
                    // TODO: Check if hsv.s > 0.5 is really nesseccary
                    let alpha: Float = (hsv.h > minHueAngle && hsv.h < maxHueAngle && hsv.s > 0.5) ? 0 : 1.0

                    cubeData[offset] = rgb[0] * alpha
                    cubeData[offset + 1] = rgb[1] * alpha
                    cubeData[offset + 2] = rgb[2] * alpha
                    cubeData[offset + 3] = alpha
                    offset += 4
                }
            }
        }
        let b = cubeData.withUnsafeBufferPointer { Data(buffer: $0) }
        let data = b as NSData

        let colorCube = CIFilter(name: "CIColorCube", parameters: [
            "inputCubeDimension": size,
            "inputCubeData": data
            ])
        return colorCube!
    }


}


//----------------------------------------------------
//MARK: VIewController Extensions For Setting Up ARKit
//----------------------------------------------------

extension UIViewController{

    /// The Type Of Plane Detection Needed During The ARSession
    ///
    /// - Horizontal: Horizontal Plane Detection
    /// - Vertical: Vertical Plane Detection
    /// - Both: Horizontal & Vertical Plane Detection
    /// - None: No Plane Detection
    enum ARPlaneDetection {

        case Horizontal, Vertical, Both, None
    }

    /// The Type Of Debug Options Needed During The ARSession
    ///
    /// - FeaturePoints: Show Feature Points
    /// - WorldOrigin: Show The World Origin
    /// - Both: Show Both Feature Points & The World Origin
    /// - **None**: Show None (Development Build)
    enum ARDebugOptions{

        case FeaturePoints, WorldOrigin, Both, None
    }

    /// The Type Of ARConfiguration Needed
    ///
    /// - ResetTracking: Resets World Tracking
    /// - RemoveAnchors: Removes All Existing Session Anchors
    /// - **ResetAndRemove**: Resets World Tracking & Removes All Existing Anchors
    /// - None: No Congifuration
    enum ARConfigurationOptions{

        case ResetTracking, RemoveAnchors, ResetAndRemove, None

    }

    /// Sets The ARSession Debug Options
    ///
    /// - Parameter options: ARDebugOptions
    /// - Returns: SCNDebugOptions
    func debug(_ options: ARDebugOptions) -> SCNDebugOptions{

        switch options {

        case .FeaturePoints:
            return [ARSCNDebugOptions.showFeaturePoints]
        case .WorldOrigin:
            return [ARSCNDebugOptions.showWorldOrigin]
        case .Both:
            return [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        case .None:
            return []
        }
    }

    /// Sets The ARSession Run Options
    ///
    /// - Parameter configuration: ARConfigurationOptions
    /// - Returns: ARSession.RunOptions
    func runOptions(_ configuration: ARConfigurationOptions) -> ARSession.RunOptions{

        switch configuration {

        case .ResetTracking:
            return [.resetTracking]
        case .RemoveAnchors:
            return [.removeExistingAnchors]
        case .ResetAndRemove:
            return [.resetTracking, .removeExistingAnchors ]
        case .None:
            return []
        }
    }
}

//------------------------------------------------
//MARK: ARSession Extension To Log Tracking States
//------------------------------------------------

extension ARCamera.TrackingState: CustomStringConvertible{

    public var description: String {

        switch self {

        case .notAvailable:                         return "Tracking Unavailable"
        case .limited(.excessiveMotion):            return "Please Slow Your Movement"
        case .limited(.insufficientFeatures):       return "Try To Point At A Flat Surface"
        case .limited(.initializing):               return "Initializing"
        case .limited(.relocalizing):               return "Relocalizing"
        case .normal:                               return ""
        case .limited(_):
            return "no Descripted"
        }
    }

}

//-------------------------------
//MARK ARFrame WorldMappingStatus
//-------------------------------


@available(iOS 12.0, *)
extension ARFrame.WorldMappingStatus: CustomStringConvertible{

    public var description: String {
        switch self {
        case .notAvailable:
            return "World Mapping Not Available"
        case .limited:
            return "World Mapping Is Limited"
        case .extending:
            return "World Mapping Is Extending"
        case .mapped:
            return "World Is Succesfully Mapped"
        default:
            return "?"

        }

    }
}

//--------------------------------------------
//MARK: ARSCNView Extension For Lighting Setup
//--------------------------------------------

extension ARSCNView{

    /// Applies Auto Lighting Of The ARSCNView
    func applyLighting() {
        self.autoenablesDefaultLighting = true
        self.automaticallyUpdatesLighting = true
    }
}


