//
//  ViewController.swift
//  CardAR
//
//  Created by Zach Eriksen on 6/16/18.
//  Copyright © 2018 Zach Eriksen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit

enum State {
    case home
    case deposit
    case payment
    case transfer
    case location
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planeNode: SCNNode!
    var titleNode: SCNNode!
    var statusTitleNode: SCNNode!
    var accountTitleNameNode: SCNNode!
    
    var depositButton: SCNNode!
    var paymentButton: SCNNode!
    var transferButton: SCNNode!
    
    var currentState: State = .deposit {
        didSet {
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
        createDepositButton()
        createPaymentButton()
        createTransferButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let images = ARReferenceImage.referenceImages(inGroupNamed: "Images", bundle: Bundle.main) else {
            fatalError("No Images")
        }
        configuration.trackingImages = images
        configuration.maximumNumberOfTrackedImages = images.count
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func createDepositButton() {
        let geo = SCNBox(width: 0.005, height: 0, length: 0.005, chamferRadius: 1)
        geo.firstMaterial?.diffuse.contents = UIImage(named: "sc-deposit")
        geo.firstMaterial?.specular.contents = UIColor.white
        let button = SCNNode(geometry: geo)
        button.position.y = -0.001
        let back = SCNCylinder(radius: 0.0065, height: 0.001)
        back.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 44.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        depositButton = SCNNode(geometry: back)
        depositButton.eulerAngles.x = -.pi / 2
        depositButton.position = SCNVector3Zero
        depositButton.position.x = -0.03
        depositButton.position.y = -0.035
        depositButton.addChildNode(button)
    }
    
    private func createTransferButton() {
        let geo = SCNBox(width: 0.005, height: 0, length: 0.005, chamferRadius: 1)
        geo.firstMaterial?.diffuse.contents = UIImage(named: "sc-transfer")
        geo.firstMaterial?.specular.contents = UIColor.white
        let button = SCNNode(geometry: geo)
        button.position.y = -0.001
        let back = SCNCylinder(radius: 0.0065, height: 0.001)
        back.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 44.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        transferButton = SCNNode(geometry: back)
        transferButton.eulerAngles.x = -.pi / 2
        transferButton.position = SCNVector3Zero
        transferButton.position.x = 0.03
        transferButton.position.y = -0.035
        transferButton.addChildNode(button)
    }
    
    private func createPaymentButton() {
        let geo = SCNBox(width: 0.005, height: 0, length: 0.005, chamferRadius: 1)
        geo.firstMaterial?.diffuse.contents = UIImage(named: "sc-payment")
        geo.firstMaterial?.specular.contents = UIColor.white
        let button = SCNNode(geometry: geo)
        button.position.y = -0.001
        let back = SCNCylinder(radius: 0.0065, height: 0.001)
        back.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 44.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        paymentButton = SCNNode(geometry: back)
        paymentButton.eulerAngles.x = -.pi / 2
        paymentButton.position = SCNVector3Zero
        paymentButton.position.y = -0.035
        paymentButton.position.x = 0
        paymentButton.addChildNode(button)
    }
    
    private func createTitleView(withText text: String) {
        if let titleNode = titleNode {
            titleNode.removeFromParentNode()
        }
        let geo = SCNText(string: text, extrusionDepth: 1)
        titleNode = SCNNode(geometry: geo)
        titleNode.position.y = -0.055
        titleNode.position.x = -0.04
        titleNode.position.z = 0
        titleNode.scale = SCNVector3(0.00075, 0.00075, 0.00075)
        planeNode.addChildNode(titleNode)
    }
    
    private func createStatusTitleView(withText text: String) {
        if let statusTitleNode = statusTitleNode {
            statusTitleNode.removeFromParentNode()
        }
        let geo = SCNText(string: text, extrusionDepth: 1)
        statusTitleNode = SCNNode(geometry: geo)
        statusTitleNode.position.y = 0.03
        statusTitleNode.position.x = -0.04
        statusTitleNode.position.z = 0
        statusTitleNode.scale = SCNVector3(0.0005, 0.0005, 0.0005)
        planeNode.addChildNode(statusTitleNode)
    }
    
    private func createAccountTitleNameView(withText text: String) {
        if let statusTitleNode = accountTitleNameNode {
            statusTitleNode.removeFromParentNode()
        }
        let geo = SCNText(string: text, extrusionDepth: 1)
        geo.firstMaterial?.diffuse.contents = UIColor.white
        accountTitleNameNode = SCNNode(geometry: geo)
        accountTitleNameNode.position.y = 0.04
        accountTitleNameNode.position.x = -0.04
        accountTitleNameNode.position.z = 0
        accountTitleNameNode.scale = SCNVector3(0.0006, 0.0006, 0.0006)
        planeNode.addChildNode(accountTitleNameNode)
    }

    // MARK: - ARSCNViewDelegate

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                 height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            
            planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.addChildNode(depositButton)
            planeNode.addChildNode(paymentButton)
            planeNode.addChildNode(transferButton)
            createTitleView(withText: "Home")
            update()
        
            node.addChildNode(planeNode)
        }
        return node
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

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if touch.view == sceneView {
            let touchLocation: CGPoint = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(touchLocation, options: nil).first else {
                return
            }
            let node = result.node
            
            
            switch node {
            case transferButton, transferButton.childNodes.first!: transferButtonTapped()
            case paymentButton, paymentButton.childNodes.first!: paymentButtonTapped()
            case depositButton, depositButton.childNodes.first!: depositButtonTapped()
            default: print("Unknown")
            }
    
        }
    }
    
    func check(node: SCNNode, forButton button: SCNNode) -> Bool {
        let childeren = button.childNodes
        return childeren.map{ $0 == node }.reduce(false, { (lhs, rhs) -> Bool in
            return lhs || rhs
        })
    }
    
    func update() {
        switch currentState {
        case .home: showHome()
        case .deposit: showDeposit()
        case .payment: showPayment()
        case .transfer: showTransfer()
        case .location: showLocation()
        }
    }
    
    func transferButtonTapped() {
        currentState = .transfer
    }
    
    func paymentButtonTapped() {
        currentState = .payment
    }
    
    func depositButtonTapped() {
        currentState = .deposit
    }
    
    func showHome() {
//        planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "card")
    }
    
    func showTransfer() {
        createTitleView(withText: "Transfer")
        createStatusTitleView(withText: "Last Transfer: $500 to mmoke123")
        createAccountTitleNameView(withText: "Parker's CheckCard    $4,345.34")
    }
    
    func showPayment() {
        createTitleView(withText: "Payment")
        createStatusTitleView(withText: "Next Payment: July 25th 2018")
        createAccountTitleNameView(withText: "Parker's CheckCard    $4,345.34")
    }
    
    func showDeposit() {
        createTitleView(withText: "Deposit")
        createStatusTitleView(withText: "Last Deposit: $234.64 on July 3rd")
        createAccountTitleNameView(withText: "Parker's CheckCard    $4,345.34")
    }
    
    func showLocation() {
        
    }
}
