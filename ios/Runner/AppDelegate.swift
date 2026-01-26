import Flutter
import UIKit
import GoogleMaps
import ActivityKit

struct BusETAAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var eta: Int
    var status: String
  }
  
  var tripId: String
  var routeName: String
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var currentActivity: Any?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA6WSHJ8R0AMDhhk0e_-Sn0KLEwSB60QKw")
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup MethodChannel for Live Activities
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.geovoy.geovoy_app/eta_live_activity",
        binaryMessenger: controller.binaryMessenger
      )
      
      channel.setMethodCallHandler { [weak self] (call, result) in
        self?.handleMethodCall(call: call, result: result)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startLiveActivity":
      startLiveActivity(call: call, result: result)
    case "updateLiveActivity":
      updateLiveActivity(call: call, result: result)
    case "endLiveActivity":
      endLiveActivity(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func startLiveActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(FlutterError(code: "UNSUPPORTED", message: "Live Activities require iOS 16.2+", details: nil))
      return
    }
    
    guard let args = call.arguments as? [String: Any],
          let tripId = args["tripId"] as? String,
          let routeName = args["routeName"] as? String,
          let eta = args["eta"] as? Int,
          let status = args["status"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }
    
    // End any existing activity first
    Task {
      if let activity = currentActivity as? Activity<BusETAAttributes> {
          await activity.end(nil, dismissalPolicy: ActivityUIDismissalPolicy.immediate)
      }
      
      let attributes = BusETAAttributes(tripId: tripId, routeName: routeName)
      let contentState = BusETAAttributes.ContentState(eta: eta, status: status)
      
      do {
        let activity = try Activity<BusETAAttributes>.request(
          attributes: attributes,
          contentState: contentState,
          pushType: nil
        )
        
        currentActivity = activity
        print("🍎 Live Activity started: \(tripId)")
        result(true)
      } catch {
        print("❌ Error starting Live Activity: \(error)")
        result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
      }
    }
  }
  
  private func updateLiveActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(FlutterError(code: "UNSUPPORTED", message: "Live Activities require iOS 16.2+", details: nil))
      return
    }
    
    guard let activity = currentActivity as? Activity<BusETAAttributes> else {
      result(FlutterError(code: "NO_ACTIVITY", message: "No active Live Activity to update", details: nil))
      return
    }
    
    guard let args = call.arguments as? [String: Any],
          let eta = args["eta"] as? Int,
          let status = args["status"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
      return
    }
    
    Task {
      let contentState = BusETAAttributes.ContentState(eta: eta, status: status)
      await activity.update(using: contentState)
      print("🍎 Live Activity updated: ETA=\(eta) min")
      result(true)
    }
  }
  
  private func endLiveActivity(result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(FlutterError(code: "UNSUPPORTED", message: "Live Activities require iOS 16.2+", details: nil))
      return
    }
    
    guard let activity = currentActivity as? Activity<BusETAAttributes> else {
      result(true) // Already ended, consider it success
      return
    }
    
    Task {
      await activity.end(nil, dismissalPolicy: ActivityUIDismissalPolicy.immediate)
      currentActivity = nil
      print("🍎 Live Activity ended")
      result(true)
    }
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    // End all active Live Activities when the app is killed/swiped away
    if #available(iOS 16.2, *) {
      let semaphore = DispatchSemaphore(value: 0)
      Task.detached(priority: .high) {
        for activity in Activity<BusETAAttributes>.activities {
          print("🍎 Force ending activity on term: \(activity.id)")
          await activity.end(nil, dismissalPolicy: .immediate)
        }
        semaphore.signal()
      }
      _ = semaphore.wait(timeout: .now() + 1.5)
    }
    super.applicationWillTerminate(application)
  }
}
