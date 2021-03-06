import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var bitesCountLabel: UILabel!
    @IBOutlet weak var chewCountLabel: UILabel!

    var chewCount = 0  {
        didSet {
            DispatchQueue.main.async {
                self.chewCountLabel.text = "\(self.chewCount)"
            }
        }
    }

    var bitesCount = 0{
        didSet {
            DispatchQueue.main.async {
                self.bitesCountLabel.text = "\(self.bitesCount)"
            }
        }
    }

    lazy var biteDetector: BiteDetector = { BiteDetector(delegate: self) }()
    lazy var chewDetector: ChewDetector = { ChewDetector(delegate: self) }()

    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()

    var session: ARSession { return sceneView.session }

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
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

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        statusViewController.showMessage("""
        SESSION INTERRUPTED
        The session will be reset after the interruption has ended.
        """, autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            self.resetTracking()
        }
    }

    func resetTracking() {
        statusViewController.showMessage("STARTING A NEW SESSION")
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func restartExperience() {
        statusViewController.isRestartExperienceButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.statusViewController.isRestartExperienceButtonEnabled = true
        }
        resetTracking()
    }

    func displayErrorMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard let jawOpen = faceAnchor.blendShapes[.jawOpen] as? Float,
            let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as? Float,
            let mouthPucker = faceAnchor.blendShapes[.mouthPucker] as? Float,
            let mouthClose = faceAnchor.blendShapes[.mouthClose] as? Float,
            let mouthFrownLeft = faceAnchor.blendShapes[.mouthFrownLeft] as? Float,
            let mouthFrownRight = faceAnchor.blendShapes[.mouthFrownRight] as? Float,
            let mouthLowerDownLeft = faceAnchor.blendShapes[.mouthLowerDownLeft] as? Float,
            let mouthLowerDownRight = faceAnchor.blendShapes[.mouthLowerDownRight] as? Float,
            let mouthStretchRight = faceAnchor.blendShapes[.mouthStretchRight] as? Float,
            let mouthStretchLeft = faceAnchor.blendShapes[.mouthStretchLeft] as? Float
            else { return }
        let bite = Double(jawOpen + mouthLowerDownLeft + mouthLowerDownRight + mouthStretchRight + mouthStretchLeft + mouthFrownRight +
            1 - mouthFrownLeft + 1 - mouthPucker)
        biteDetector.input(value: bite)
        let chew = Double(jawOpen + mouthLowerDownLeft + mouthLowerDownRight + mouthStretchRight + mouthStretchLeft + mouthFrownRight + mouthFrownLeft + mouthPucker + mouthFunnel + mouthClose)
        chewDetector.input(value: chew)
    }
}

extension ViewController: BiteDetectorDelegate, ChewDetectorDelegate {
    func biteDetected() {
        bitesCount += 1
    }

    func chewDetected() {
        chewCount += 1
    }
}
