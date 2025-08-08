import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import AppTrackingTransparency
import AdSupport

@main
@objc class AppDelegate: FlutterAppDelegate {
  override init() {
    super.init()
    print("=== APPDELEGATE INITIALIZED ===")
  }
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // Enable APNS debugging
    print("=== APNS DEBUGGING ENABLED ===")
    print("App Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
    print("Device: \(UIDevice.current.name)")
    print("iOS Version: \(UIDevice.current.systemVersion)")
    
    // Set notification delegate
    UNUserNotificationCenter.current().delegate = self
    print("Notification delegate set")
    
    // Check if push notifications are enabled
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("=== NOTIFICATION SETTINGS ===")
      print("Authorization Status: \(settings.authorizationStatus.rawValue)")
      print("Alert Setting: \(settings.alertSetting.rawValue)")
      print("Badge Setting: \(settings.badgeSetting.rawValue)")
      print("Sound Setting: \(settings.soundSetting.rawValue)")
      print("Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
      print("Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
    }
    
    // Register for remote notifications
    application.registerForRemoteNotifications()
    print("=== REGISTERING FOR REMOTE NOTIFICATIONS ===")
    print("Registered for remote notifications")
    
    // Request App Tracking Transparency permission
    requestTrackingAuthorization()
    
    // Try to get APNS token directly
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      if let apnsToken = Messaging.messaging().apnsToken {
        print("=== APNS TOKEN FOUND ===")
        print("APNS Token: \(apnsToken)")
      } else {
        print("=== NO APNS TOKEN AVAILABLE ===")
        print("This is expected in simulator")
      }
    }
    
    // Test if AppDelegate is working
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      print("🔥🔥🔥 APPDELEGATE WORKING - CHECK XCODE CONSOLE 🔥🔥🔥")
      print("=== APPDELEGATE TEST - This should appear in Xcode console ===")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup method channel for App Tracking Transparency
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app_tracking_transparency", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] (call, result) in
        switch call.method {
        case "requestTrackingAuthorization":
          if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
              DispatchQueue.main.async {
                self?.handleTrackingAuthorizationStatus(status)
                result("success")
              }
            }
          } else {
            result("success")
          }
        case "getTrackingAuthorizationStatus":
          if #available(iOS 14.0, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            var statusString = ""
            switch status {
            case .authorized: statusString = "authorized"
            case .denied: statusString = "denied"
            case .restricted: statusString = "restricted"
            case .notDetermined: statusString = "notDetermined"
            @unknown default: statusString = "unknown"
            }
            result(statusString)
          } else {
            result("authorized")
          }
        case "getAdvertisingIdentifier":
          if #available(iOS 14.0, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            if status == .authorized {
              let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
              result(idfa)
            } else {
              result("")
            }
          } else {
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            result(idfa)
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle APNS token registration
  override func application(_ application: UIApplication,
                          didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    
    print("=== APNS DEVICE TOKEN RECEIVED ===")
    print("APNS Device Token: \(tokenString)")
    print("Token Length: \(deviceToken.count) bytes")
    print("Token Hex: \(tokenString)")
    
    // Set the APNS token for Firebase
    Messaging.messaging().apnsToken = deviceToken
    print("APNS token set for Firebase Messaging")
    
    // Get FCM token after APNS token is set
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error getting FCM token: \(error)")
      } else if let token = token {
        print("=== FCM TOKEN RECEIVED ===")
        print("FCM Token: \(token)")
      }
    }
  }
  
  // Handle APNS token registration failure
  override func application(_ application: UIApplication,
                          didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("=== APNS REGISTRATION FAILED ===")
    print("Failed to register for remote notifications: \(error)")
    print("Error Description: \(error.localizedDescription)")
    
    // Check if it's a simulator
    #if targetEnvironment(simulator)
    print("Running on iOS Simulator - APNS tokens are not available in simulator")
    #else
    print("Running on real device - APNS registration should work")
    #endif
  }
  
  // Handle incoming notifications when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                     willPresent notification: UNNotification,
                                     withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("=== FOREGROUND NOTIFICATION RECEIVED ===")
    print("Notification Title: \(notification.request.content.title)")
    print("Notification Body: \(notification.request.content.body)")
    print("Notification User Info: \(notification.request.content.userInfo)")
    
    // Check if this is a cart_item_added notification
    let userInfo = notification.request.content.userInfo
    if let type = userInfo["type"] as? String, type == "cart_item_added" {
      print("=== CART ITEM NOTIFICATION IN FOREGROUND ===")
      print("Manually triggering Flutter handler for cart notification")
      
      // Manually trigger Flutter's notification handler
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "notification_handler", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("handleForegroundNotification", arguments: userInfo)
        print("=== FLUTTER HANDLER TRIGGERED ===")
      }
      
      // Don't show the notification banner
      completionHandler([])
    } else {
      // Show the notification for other types
      if #available(iOS 14.0, *) {
        completionHandler([.banner, .badge, .sound])
      } else {
        completionHandler([.alert, .badge, .sound])
      }
    }
  }
  
  // MARK: - App Tracking Transparency
  
  private func requestTrackingAuthorization() {
    // Delay the request to ensure the app is fully loaded
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      if #available(iOS 14.0, *) {
        let status = ATTrackingManager.trackingAuthorizationStatus
        print("=== APP TRACKING TRANSPARENCY STATUS ===")
        print("Current Status: \(status.rawValue)")
        
        switch status {
        case .notDetermined:
          print("Requesting tracking authorization...")
          ATTrackingManager.requestTrackingAuthorization { newStatus in
            DispatchQueue.main.async {
              self.handleTrackingAuthorizationStatus(newStatus)
            }
          }
        case .authorized:
          print("Tracking already authorized")
          self.handleTrackingAuthorizationStatus(.authorized)
        case .denied:
          print("Tracking denied by user")
          self.handleTrackingAuthorizationStatus(.denied)
        case .restricted:
          print("Tracking restricted by system")
          self.handleTrackingAuthorizationStatus(.restricted)
        @unknown default:
          print("Unknown tracking status")
          self.handleTrackingAuthorizationStatus(.denied)
        }
      } else {
        // iOS 13 and below - tracking is always allowed
        print("iOS 13 or below - tracking always allowed")
        self.handleTrackingAuthorizationStatus(.authorized)
      }
    }
  }
  
  private func handleTrackingAuthorizationStatus(_ status: ATTrackingManager.AuthorizationStatus) {
    print("=== HANDLING TRACKING AUTHORIZATION ===")
    print("Status: \(status.rawValue)")
    
    var statusString = ""
    switch status {
    case .authorized:
      statusString = "authorized"
      print("✅ Tracking authorized - can collect IDFA")
      // Get IDFA if authorized
      if #available(iOS 14.0, *) {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        print("IDFA: \(idfa)")
      }
    case .denied:
      statusString = "denied"
      print("❌ Tracking denied - cannot collect IDFA")
    case .restricted:
      statusString = "restricted"
      print("🚫 Tracking restricted - cannot collect IDFA")
    case .notDetermined:
      statusString = "notDetermined"
      print("❓ Tracking not determined")
    @unknown default:
      statusString = "unknown"
      print("❓ Unknown tracking status")
    }
    
    // Notify Flutter about the tracking status
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app_tracking_transparency", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("trackingAuthorizationStatusChanged", arguments: statusString)
      print("=== FLUTTER NOTIFIED OF TRACKING STATUS ===")
    }
  }
  
}
