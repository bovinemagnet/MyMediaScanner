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
      switch call.method {
      case "recogniseText":
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "imagePath required", details: nil))
          return
        }
        VisionOcrHelper.recogniseText(fromFile: imagePath) { text in
          result(text)
        }
      case "recogniseTextStructured":
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "imagePath required", details: nil))
          return
        }
        VisionOcrHelper.recogniseTextStructured(fromFile: imagePath) { blocks in
          result(blocks)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Register security-scoped bookmarks channel. The App Sandbox only
    // grants access to user-picked folders for the current process, so
    // the FLAC library root is persisted as a bookmark and re-armed on
    // the next launch.
    let bookmarksChannel = FlutterMethodChannel(
      name: "com.mymediascanner/secure_bookmarks",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    bookmarksChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "createBookmark":
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "path required", details: nil))
          return
        }
        result(SecureBookmarkHelper.createBookmark(forPath: path))
      case "startAccess":
        guard let args = call.arguments as? [String: Any],
              let bookmark = args["bookmark"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "bookmark required", details: nil))
          return
        }
        result(SecureBookmarkHelper.startAccess(bookmarkBase64: bookmark))
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}

/// Persists sandbox access to user-picked folders across launches via
/// security-scoped bookmarks.
class SecureBookmarkHelper {
  /// URLs currently under security-scoped access, retained so the scope
  /// stays live for the app's lifetime (released implicitly at exit).
  private static var activeUrls: [String: URL] = [:]

  /// Creates a security-scoped bookmark for [path]. Only succeeds while
  /// the app still holds live access to it (i.e. straight after the
  /// user picked the folder in the open panel).
  static func createBookmark(forPath path: String) -> String? {
    let url = URL(fileURLWithPath: path)
    guard let data = try? url.bookmarkData(
      options: .withSecurityScope,
      includingResourceValuesForKeys: nil,
      relativeTo: nil
    ) else { return nil }
    return data.base64EncodedString()
  }

  /// Resolves the bookmark and starts security-scoped access. Returns
  /// the bookmark to store going forward — a renewed blob when macOS
  /// flagged the stored one as stale — or nil when access could not be
  /// restored (the user needs to re-pick the folder).
  static func startAccess(bookmarkBase64: String) -> String? {
    guard let data = Data(base64Encoded: bookmarkBase64) else { return nil }
    var isStale = false
    guard let url = try? URL(
      resolvingBookmarkData: data,
      options: .withSecurityScope,
      relativeTo: nil,
      bookmarkDataIsStale: &isStale
    ) else { return nil }
    guard url.startAccessingSecurityScopedResource() else { return nil }
    activeUrls[url.path] = url
    if isStale, let renewed = try? url.bookmarkData(
      options: .withSecurityScope,
      includingResourceValuesForKeys: nil,
      relativeTo: nil
    ) {
      return renewed.base64EncodedString()
    }
    return bookmarkBase64
  }
}

/// Uses macOS Vision framework for on-device text recognition.
class VisionOcrHelper {
  static func recogniseText(fromFile path: String, completion: @escaping (String?) -> Void) {
    recogniseObservations(fromFile: path) { observations in
      guard let observations = observations, !observations.isEmpty else {
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
  }

  /// Returns one entry per recognised text observation, each a map with
  /// 'text' (String), 'confidence' (Double, 0..1) and 'area' (Double,
  /// normalised bounding-box area 0..1), ordered by area descending.
  static func recogniseTextStructured(fromFile path: String, completion: @escaping ([[String: Any]]?) -> Void) {
    recogniseObservations(fromFile: path) { observations in
      guard let observations = observations, !observations.isEmpty else {
        completion(nil)
        return
      }

      let blocks: [[String: Any]] = observations.compactMap { observation in
        guard let candidate = observation.topCandidates(1).first else {
          return nil
        }
        let area = observation.boundingBox.width * observation.boundingBox.height
        return [
          "text": candidate.string,
          "confidence": Double(candidate.confidence),
          "area": Double(area),
        ]
      }.sorted { a, b in
        (a["area"] as? Double ?? 0) > (b["area"] as? Double ?? 0)
      }

      completion(blocks)
    }
  }

  /// Shared Vision request: loads the image at [path] and performs text
  /// recognition, returning the raw observations (or nil on failure).
  private static func recogniseObservations(
    fromFile path: String,
    completion: @escaping ([VNRecognizedTextObservation]?) -> Void
  ) {
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

      completion(observations)
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
