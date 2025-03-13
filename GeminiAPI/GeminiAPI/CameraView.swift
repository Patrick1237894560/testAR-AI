import AVFoundation
import UIKit
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func captureOutput(
            _ output: AVCaptureOutput,
            didOutput sampleBuffer: CMSampleBuffer,
            from connection: AVCaptureConnection
        ) {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                DispatchQueue.main.async {
                    self.parent.frame = UIImage(cgImage: cgImage)
                }
            }
        }
    }

    @Binding var frame: UIImage?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return UIViewController()
        }

        captureSession.addInput(videoInput)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let viewController = UIViewController()
        let cameraView = UIView(frame: UIScreen.main.bounds)
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
        viewController.view.addSubview(cameraView)

        captureSession.startRunning()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
