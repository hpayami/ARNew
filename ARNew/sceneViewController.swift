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
import AVKit
import MobileCoreServices

class sceneViewController: UIViewController,ARSCNViewDelegate,ARSessionDelegate  {

    //MARK: Declaration

    // For rotataion of videonode
    var currentAngleY: Float = 0.0

    //MARK: Position Center
    let position = CGPoint()

    //MARK:Declaration of ARSCNView

    let arView: ARSCNView = {
        let view = ARSCNView()

        return view
    }()

    //MARK:Declation of recorder
    var recorder : RecordAR?


    let configuration = ARWorldTrackingConfiguration()
    let augmentedRealitySession = ARSession()


    //MARK: Video Editor Declaration
    // Create a custom transitioning animation object
    //   This is an instance of our CustomViewControllerAnimatedTransitioning class
    let transition = CustomViewControllerAnimatedTransitioning()






    //MARK: Declaration VideoNode,VideoType,VideoFilter
    var planeNode = SCNNode()


    // Create SceneKit videoNode to hold the spritekit scene.
    let videoNode = SCNNode()



    var videoFile : String = ""
    var videoProcessingFunction : String = ""

    var greenScreenFiles : [String] = [String]()
    var CompositeVideoFiles : [String] = [String]()

    var videoFilePicker : [String] = [String]()
    var videoProcessingFuncPicker : [String] = [String]()









    //MARK:Declaration UIButton For Start a video recording

    lazy var recorderButton: UIButton = {

        // Add button for screenshot

        let btn = UIButton(type: .system)
        btn.setTitle("Record", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x:0,y:0,width: 110,height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.90)
        btn.layer.cornerRadius = btn.bounds.height / 2
        btn.tag = 0
        return btn

    }()

    //MARK:Declaration UIButton For pausing a video recording

    lazy var pauseButton: UIButton = {



        let btn = UIButton(type: .system)
        btn.setTitle("Pause", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x:0,y:0,width: 60,height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width * 0.15, y: UIScreen.main.bounds.height * 0.90)
        btn.layer.cornerRadius = btn.bounds.height / 2
        btn.alpha = 0.3
        btn.isEnabled = false
        return btn

    }()


    //gif UIButton for capturing a gif image
    lazy var gifButton: UIButton = {

        // Add button for screenshot

        let btn = UIButton(type: .system)
        btn.setTitle("Gif", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.frame = CGRect(x:0,y:0,width: 110,height: 60)
        btn.center = CGPoint(x: UIScreen.main.bounds.width * 0.85, y: UIScreen.main.bounds.height * 0.90)
        btn.layer.cornerRadius = btn.bounds.height / 2
        return btn

    }()


    override func viewDidLoad() {
        super.viewDidLoad()






        arView.delegate = self



        // Set showsStatistics to true to show stats on fps and timing information
        arView.showsStatistics = false
        arView.preferredFramesPerSecond = 30
        arView.contentScaleFactor = 1.0

        //Call Methods
        handleActions()
        setupControlls()
        initializingControlls()
        arView.session.run(configuration, options: [])

        //initialize ARSCNView
        recorder = RecordAR(ARSceneKit: arView)
        recorder?.inputViewOrientations = [.portrait]

    }




    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configuration.planeDetection = .horizontal

        recorder?.prepare(configuration)

        arView.session.run(configuration)


    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        recorder?.rest()

        arView.session.pause()


    }

    //MARK:Show Video On the Scene

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        // Get Video URL and create AV Player
        let filePath = Bundle.main.path(forResource: "simple", ofType: "mp4")
        let videoURL = NSURL(fileURLWithPath: filePath!)
        let player = AVPlayer(url: videoURL as URL)

        // Set geometry of the SceneKit node to be a plane, and rotate it to be flat with the image
        videoNode.geometry = SCNPlane(width: 0.9,
                                      height:0.9)


        videoNode.position = SCNVector3(x: 0, y: 0, z: -0.2)
        //Set the video AVPlayer as the contents of the video node's material.
        videoNode.geometry?.firstMaterial?.diffuse.contents = player
        videoNode.geometry?.firstMaterial?.isDoubleSided = true

        // Alpha transparancy stuff
        let chromaKeyMaterial = ChromaKeyMaterial()
        chromaKeyMaterial.diffuse.contents = player
        videoNode.geometry!.materials = [chromaKeyMaterial]

        //video does not start without delaying the player
        //playing the video before just results in [SceneKit] Error: Cannot get pixel buffer (CVPixelBufferRef)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            player.seek(to:CMTimeMakeWithSeconds(1, preferredTimescale: 1000))
            player.play()
        }
        // Loop video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }

        // Add videoNode to ARAnchor
      //  node.addChildNode(videoNode)

        // Add ARAnchor node to the root node of the scene
        self.arView.scene.rootNode.addChildNode(videoNode)
        return videoNode
    }


    /// Scales An SCNNode
    ///
    /// - Parameter gesture: UIPinchGestureRecognizer
    @objc func scalePiece(_ gesture  : UIPinchGestureRecognizer) {

        if gesture.state == .changed {
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((videoNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((videoNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((videoNode.scale.z))
            videoNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY),Float(pinchScaleZ))

            gesture.scale = 1

        }

        if gesture.state == .ended { }

    }


    
    /// Removes Node on SCNNode
    ///
    /// - Parameter:UILongPressGestureRecognizer
    @objc func removeNode(removegestureRecognize : UILongPressGestureRecognizer){

        if removegestureRecognize.state != .began {
            return
        }
        let holdPoint: CGPoint? = removegestureRecognize.location(in: arView)
        let result = arView.hitTest(holdPoint ?? CGPoint.zero, options: [
            SCNHitTestOption.boundingBoxOnly: NSNumber(value: true),
            SCNHitTestOption.firstFoundOnly: NSNumber(value: true)
            ])
        if result.count == 0 {
            return
        }

        let hitResult: SCNHitTestResult? = result.first
        hitResult?.node.parent?.removeFromParentNode()

    }



    /// Moves An SCNNode
    ///
    /// - Parameter:UIPanGestureRecognizer
    @objc func moveNode(gestureRecognizer : UIPanGestureRecognizer){



    }



    //MARK: Reset Scene

    @objc func handleResetButtonTapped(){
        resetScene()
    }

    func resetScene(){

        arView.session.pause()
        arView.session.run(configuration, options: [.removeExistingAnchors,.resetTracking])
    }





    //Add Video On Screen
    @objc func addVideo(){
        // Get Video URL and create AV Player
        let filePath = Bundle.main.path(forResource: "simple", ofType: "mp4")
        let videoURL = NSURL(fileURLWithPath: filePath!)
        let player = AVPlayer(url: videoURL as URL)

        // Set geometry of the SceneKit node to be a plane, and rotate it to be flat with the image
        videoNode.geometry = SCNPlane(width: 0.9,
                                      height:0.9)


        //Set the video AVPlayer as the contents of the video node's material.
        videoNode.geometry?.firstMaterial?.diffuse.contents = player
        videoNode.geometry?.firstMaterial?.isDoubleSided = true

        // Alpha transparancy stuff
        let chromaKeyMaterial = ChromaKeyMaterial()
        chromaKeyMaterial.diffuse.contents = player
        videoNode.geometry!.materials = [chromaKeyMaterial]

        //video does not start without delaying the player
        //playing the video before just results in [SceneKit] Error: Cannot get pixel buffer (CVPixelBufferRef)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            player.seek(to:CMTimeMakeWithSeconds(1, preferredTimescale: 1000))
            player.play()
        }
        // Loop video
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }

        // Add ARAnchor node to the root node of the scene
        self.arView.scene.rootNode.addChildNode(videoNode)

    }









    //MARK:Action Methods
    func  handleActions(){

        recorderButton.addTarget(self, action: #selector(recorderAction(sender:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseAction(sender:)), for: .touchUpInside)
        gifButton.addTarget(self, action: #selector(gifAction(sender:)), for: .touchUpInside)
    }


    //MARK: setupControlls
    ///
    ///
    func setupControlls(){
        view.addSubview(arView)
        view.addSubview(recorderButton)
        view.addSubview(gifButton)
        view.addSubview(pauseButton)


    }

    //MARK: initializingControlls
    ///
    func initializingControlls(){

        view.backgroundColor = UIColor.clear
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        arView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true











        // Add a gesture recognizer
        let tapGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scalePiece))
        arView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false


        // Add a pan gesture recognizer
        let gestureRecognize = UIPanGestureRecognizer(target: self, action: #selector(moveNode))
        arView.addGestureRecognizer(gestureRecognize)


        //Add a pan gesture recognier For Remove Node
        let removegestureRecognize = UILongPressGestureRecognizer(target: self, action: #selector(removeNode))
        arView.addGestureRecognizer(removegestureRecognize)
        removegestureRecognize.minimumPressDuration = 0.5





    }

    //MARK:Video Editor Description
    //Do not delete "Video-Temp.mp4" because this is temp video file, we'll make sure our video can be found




}
//MARK: Button Action Methods
extension sceneViewController{

    // MARK:Take a RecordVideo
    //
    @objc func recorderAction(sender:UIButton){

        if recorder?.status == .readyToRecord{
            //start recording

            recorder?.record()
            //change button title
            sender.setTitle("Stop", for: .normal)
            sender.setTitleColor(.red, for: .normal)
            //enable pause button
            pauseButton.alpha = 1
            pauseButton.isEnabled = true

            //Disable GIF button
            gifButton.alpha = 0.3
            gifButton.isEnabled = false


        }



        else if recorder?.status == .recording || recorder?.status == .paused {

            //stop recording and export vidoe to camera roll

            recorder?.stopAndExport()

            //change button title

            sender.setTitle("Record", for: .normal)
            sender.setTitleColor(.black, for: .normal)


            //enable GIF button

            gifButton.alpha = 1
            gifButton.isEnabled = true

            //Disable pause button

            pauseButton.alpha = 0.3
            pauseButton.isEnabled = false
        }
    }

    //MARK:Pause and resume method
    //
    @objc func pauseAction(sender:UIButton){


        // Pause recording

        if recorder?.status == .recording{

            recorder?.pause()

            //Change button title

            sender.setTitle("Resume", for: .normal)
            sender.setTitleColor(.blue, for: .normal)

        }
        else if recorder?.status == .paused{

            //Resume recording

            recorder?.record()

            //Change button title
            sender.setTitle("Pause", for: .normal)
            sender.setTitleColor(.black, for: .normal)

        }
    }

    //MARK:Capture  GIF method
    //

    @objc func gifAction(sender:UIButton){


        self.gifButton.isEnabled = false
        self.gifButton.alpha = 0.3
        self.recorderButton.isEnabled = false
        self.recorderButton.alpha = 0.3

        recorder?.gif(forDuration: 1.5, export: true){ _, _, _,exported in

            if exported{

                DispatchQueue.main.sync{
                    self.gifButton.isEnabled = true
                    self.gifButton.alpha = 1
                    self.recorderButton.isEnabled = true
                    self.recorderButton.alpha = 1

                }

            }
        }

    }
}

// MARK: - UIVideoEditorControllerDelegate

extension sceneViewController: UINavigationControllerDelegate {



    // After picking a video, we dismiss the picker view controller and present the editor view controller
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let videoURL = info["UIImagePickerControllerReferenceURL"] as? URL
        self.dismiss(animated: true, completion: nil)

        // We create a VideoEditorViewController to play video as well as for editing purpose
        let videoEditorViewController = VideoEditorViewController()
        videoEditorViewController.videoURL = videoURL
        videoEditorViewController.videoAsset = AVURLAsset(url: videoURL!)
        videoEditorViewController.transitioningDelegate = self as UIViewControllerTransitioningDelegate
        self.present(videoEditorViewController, animated: true, completion: nil)
    }
}

/**
 Conform to UIViewControllerTransitioningDelegate to performs custom transisioning animation
 */
extension sceneViewController: UIViewControllerTransitioningDelegate {

    // Custom presentation animation
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        transition.transitionMode = .present
        return transition
    }

    // Custom dismission animation
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        transition.transitionMode = .dismiss
        return transition
    }
}
 
