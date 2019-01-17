//
//  ViewController.swift
//  ARKitDemo
//
//  Created by Eugene on 1/16/19.
//  Copyright © 2019 Eugene. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    var ship: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLighting()
        addTapGestureToSceneView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = .showFeaturePoints
    }

    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }

    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)

        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation

        guard let shipScene = SCNScene(named: "ship.scn"),
            let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
            else { return }

        ship = shipNode
        ship!.position = SCNVector3(translation.x,
                                    translation.y,
                                    translation.z)
        sceneView.scene.rootNode.addChildNode(ship!)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let animation = SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 3)
            let action = SCNAction.repeatForever(animation)
            self.ship?.runAction(action)
        })
    }
}

extension UIViewController:ARSCNViewDelegate {
    //Every time when we need add new ARAnchor
    /*An ARAnchor is an object that represents a physical location and orientation in 3D space.*/
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)

        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue

        let planeNode = SCNNode(geometry: plane)

        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x),
                                        CGFloat(planeAnchor.center.y),
                                        CGFloat(planeAnchor.center.z))

        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }

        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)

        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x),
                                        CGFloat(planeAnchor.center.y),
                                        CGFloat(planeAnchor.center.z))
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}
