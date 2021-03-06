import UIKit
import ARKit
import CoreML

class RecordMealViewController: UIViewController {
    
    var startStopButton: UIButton!
    var biteButton: UIButton!
    var chewOpenButton: UIButton!
//    var chewClosedButton: UIButton!
    var sceneView: ARSCNView!
    var session: ARSession { return sceneView.session }
    var recording = false
    var blendShapes: [[ARFaceAnchor.BlendShapeLocation: NSNumber]] = []
    var movements = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        sceneView = ARSCNView()
        view.addSubview(sceneView)
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        startStopButton = UIButton(type: .system)
        startStopButton.setTitle("Start", for: .normal)
        startStopButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)

        biteButton = UIButton(type: .system)
        biteButton.setTitle("BITE", for: .normal)
        biteButton.backgroundColor = UIColor.orange.withAlphaComponent(0.2)

        chewOpenButton = UIButton(type: .system)
        chewOpenButton.setTitle("CHEW", for: .normal)
        chewOpenButton.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
//        chewClosedButton = UIButton(type: .system)
//        chewClosedButton.setTitle("CHEW closed", for: .normal)
//        chewClosedButton.backgroundColor = UIColor.green.withAlphaComponent(0.2)
//        let stackChewView = UIStackView(arrangedSubviews: [chewOpenButton, chewClosedButton])
//        stackChewView.distribution = .fillEqually
//        stackChewView.axis = .horizontal
//        stackChewView.spacing = 20
        
        let stackView = UIStackView(arrangedSubviews: [startStopButton, biteButton, chewOpenButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 60
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        disableUI()
    }
    
    @objc func startRecording() {
        recording = !recording
        let title = recording ? "Stop" : "Start"
        startStopButton.setTitle(title, for: .normal)
        if recording { return }

        let chartVC = ChartViewController()
        chartVC.movements = movements
        chartVC.blendShapes = blendShapes
        let nav = UINavigationController(rootViewController: chartVC)
        present(nav, animated: true, completion: nil)
        blendShapes = []
        movements = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    func resetTracking() {
        disableUI()
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension RecordMealViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        disableUI()
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        disableUI()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        disableUI()
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }
}


extension RecordMealViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        enableUI()
        
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        if recording {
            self.blendShapes.append(faceAnchor.blendShapes)
            DispatchQueue.main.async {
                
                if self.biteButton.state == .highlighted {
                    self.movements.append(2)
                } else if self.chewOpenButton.state == .highlighted {
                    self.movements.append(1)
                } else {
                    self.movements.append(0)
                }
            }
        }
    }
    
    func enableUI() {
        DispatchQueue.main.async {
            self.startStopButton.isEnabled = true
            self.biteButton.isEnabled = true
            self.chewOpenButton.isEnabled = true
//            self.chewClosedButton.isEnabled = true
        }
    }
    
    func disableUI() {
        DispatchQueue.main.async {
            self.startStopButton.isEnabled = false
            self.biteButton.isEnabled = false
            self.chewOpenButton.isEnabled = false
//            self.chewClosedButton.isEnabled = false
        }
    }
}
