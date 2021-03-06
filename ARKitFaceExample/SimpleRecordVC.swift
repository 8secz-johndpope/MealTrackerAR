import UIKit
import ARKit
import CoreML

class SimpleRecordMealViewController: UIViewController {
    
    var startStopButton: UIButton!
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
        
        let stackView = UIStackView(arrangedSubviews: [startStopButton])
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
        
        export()
        blendShapes = []
        movements = []
    }
    
    @objc func export() {
        var csvText = ""
        let fileName = "Payloads-\(Date()).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)!
        csvText.append("jawOpen,mouthLowerDown_R,mouthLowerDown_L,mouthStretch_R,mouthStretch_L,mouthPucker,mouthFrown_R,mouthFrown_L,mouthClose,mouthFunnel,mouthUpperUp_L,mouthUpperUp_R,jawForward,mouthShrugLower,mouthShrugUpper,jawRight,jawLeft,mouthDimple_L,mouthDimple_R,mouthRollLower,mouthRollUpper,mouthLeft,mouthRight,mouthSmile_L,mouthSmile_R,mouthPress_L,mouthPress_R,movement\n")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        formatter.roundingMode = .up
        for (index, blendShape) in blendShapes.enumerated() {
            let shapes = ["jawOpen","mouthLowerDown_R","mouthLowerDown_L","mouthStretch_R","mouthStretch_L","mouthPucker","mouthFrown_R","mouthFrown_L","mouthClose","mouthFunnel","mouthUpperUp_L","mouthUpperUp_R","jawForward","mouthShrugLower","mouthShrugUpper","jawRight","jawLeft","mouthDimple_L","mouthDimple_R","mouthRollLower","mouthRollUpper","mouthLeft","mouthRight","mouthSmile_L","mouthSmile_R","mouthPress_L","mouthPress_R"]
            let mouthJawShapes: [ARFaceAnchor.BlendShapeLocation] = shapes.map {
                ARFaceAnchor.BlendShapeLocation(rawValue: $0)
            }
            
            for shape in mouthJawShapes {
                let value = 10000 * Double(truncating: blendShape[shape]!)
                let rounded = Double(Int(value)) / 10000
                csvText.append("\(rounded),")
            }
            csvText.append("\(movements[index])\n")
        }
        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
        } catch {
            print("\(error)")
        }
        let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
        present(vc, animated: true, completion: nil)
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

extension SimpleRecordMealViewController: ARSessionDelegate {
    
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


extension SimpleRecordMealViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        enableUI()
        
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        if recording {
            self.blendShapes.append(faceAnchor.blendShapes)
            DispatchQueue.main.async {
                    self.movements.append(0)
            }
        }
    }
    
    func enableUI() {
        DispatchQueue.main.async {
            self.startStopButton.isEnabled = true
        }
    }
    
    func disableUI() {
        DispatchQueue.main.async {
            self.startStopButton.isEnabled = false
        }
    }
}
