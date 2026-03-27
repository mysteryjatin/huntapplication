import Flutter
import UIKit
import GoogleMaps
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Ensure Google Maps SDK is initialized before any `GoogleMap` widget renders.
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      GMSServices.provideAPIKey(apiKey)
    }

    // Ensure Google Sign-In is configured using the client id from Info.plist.
    // This avoids native crashes like: `-[GIDSignIn signInWithOptions:]`.
    if let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
       !clientID.isEmpty {
      GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
