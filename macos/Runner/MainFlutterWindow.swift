import Cocoa
import FlutterMacOS
import Vision

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Register Vision OCR method channel
    let channel = FlutterMethodChannel(
      name: "com.mymediascanner/vision_ocr",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { (call, result) in
      if call.method == "recogniseText" {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "imagePath required", details: nil))
          return
        }
        VisionOcrHelper.recogniseText(fromFile: imagePath) { text in
          result(text)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}

/// Uses macOS Vision framework for on-device text recognition.
class VisionOcrHelper {
  static func recogniseText(fromFile path: String, completion: @escaping (String?) -> Void) {
    let url = URL(fileURLWithPath: path)

    guard let cgImage = NSImage(contentsOf: url)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      completion(nil)
      return
    }

    let request = VNRecognizeTextRequest { request, error in
      guard error == nil,
            let observations = request.results as? [VNRecognizedTextObservation] else {
        completion(nil)
        return
      }

      if observations.isEmpty {
        completion(nil)
        return
      }

      // Find the observation with the largest bounding box (most prominent text)
      let sorted = observations.sorted { a, b in
        let areaA = a.boundingBox.width * a.boundingBox.height
        let areaB = b.boundingBox.width * b.boundingBox.height
        return areaA > areaB
      }

      let topText = sorted.first?.topCandidates(1).first?.string
      completion(topText)
    }

    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        DispatchQueue.main.async {
          completion(nil)
        }
      }
    }
  }
}
