//
//  AppDelegate.swift
//  plasadoapp
//
//  Created by a on 8/11/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit

import GooglePlaces
import GoogleMaps
import Firebase
import FirebaseAuth
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

import FBSDKCoreKit
let kMapsAPIKey = "AIzaSyArFTRyC24paM3yhbapNVPAVj12_vZsRO8"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    
    var window: UIWindow?
    static let isWithinUnitTest: Bool = {
        if let testClass = NSClassFromString("XCTestCase") {
            return true
        } else {
            return false
        }
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.init(red: 179/255, green: 34/255, blue: 39/255, alpha: 1)
        UIApplication.shared.statusBarStyle = .lightContent
        //UINavigationBar.appearance().tintColor = UIColor.white
        
        let attrs = [NSForegroundColorAttributeName : UIColor.white]
        if kMapsAPIKey.isEmpty {
            
            let bundleId = Bundle.main.bundleIdentifier!
            let msg = "Configure API keys inside Appdel7yegate.swift for your  bundle `\(bundleId)`, " +
            "see README.GooglePlacesClone for more information"
            print(msg)
        }
        
        //Configure API key
        GMSPlacesClient.provideAPIKey(kMapsAPIKey)
        GMSServices.provideAPIKey(kMapsAPIKey)
        
        FirebaseApp.configure()
    
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        // Just for logging to the console when we establish/tear down our socket connection.
        listenForDirectChannelStateChanges();
        
        NotificationsController.configure()
        
        if #available(iOS 8.0, *) {
            // Always register for remote notifications. This will not show a prompt to the user, as by
            // default it will provision silent notifications. We can use UNUserNotificationCenter to
            // request authorization for user-facing notifications.
            
            application.registerForRemoteNotifications()
        } else {
            // iOS 7 didn't differentiate between user-facing and other notifications, so we should just
            // register for remote notifications
            NotificationsController.shared.registerForUserFacingNotificationsFor(application)
        }
        
        printFCMToken()
        
        
        //FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        if handled {
            return handled
        }
        // If the SDK did not handle the incoming URL, check it for app link data
        let parsedUrl = BFURL(inboundURL: url, sourceApplication: sourceApplication)
        if ((parsedUrl?.appLinkData) != nil) {
            let targetUrl: URL? = parsedUrl?.targetURL
            // ...process app link data...
            UIAlertView(title: "Received link:", message: (targetUrl?.absoluteString)!, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
            return true
        }
        // ...add any other custom processing...
        return true
    }

    func printFCMToken() {
        if let token = Messaging.messaging().fcmToken {
            print("FCM Token: \(token)")
        } else {
            print("FCM Token: nil")
        }
        
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS Token: \(deviceToken.hexByteString)")
        NotificationCenter.default.post(name: APNSTokenReceivedNotification, object: nil)
        if #available(iOS 8.0, *) {
            
        } else {
            // On iOS 7, receiving a device token also means our user notifications were granted, so fire
            // the notification to update our user notifications UI
            NotificationCenter.default.post(name: UserNotificationsChangedNotification, object: nil)
        }
    }
    
    func application(_ application: UIApplication,
                     didRegister notificationSettings: UIUserNotificationSettings) {
        NotificationCenter.default.post(name: UserNotificationsChangedNotification, object: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("application:didReceiveRemoteNotification:fetchCompletionHandler: called, with notification:")
        print("\(userInfo.jsonString ?? "{}")")
        completionHandler(.newData)
    }
    

}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        printFCMToken()
    }
    
    // Direct channel data messages are delivered here, on iOS 10.0+.
    // The `shouldEstablishDirectChannel` property should be be set to |true| before data messages can
    // arrive.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        // Convert to pretty-print JSON
        guard let prettyPrinted = remoteMessage.appData.jsonString else {
            print("Received direct channel message, but could not parse as JSON: \(remoteMessage.appData)")
            return
        }
        print("Received direct channel message:\n\(prettyPrinted)")
        
        
    }
    
}

extension AppDelegate {
    func listenForDirectChannelStateChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(onMessagingDirectChannelStateChanged(_:)), name: .MessagingConnectionStateChanged, object: nil)
    }
    
    func onMessagingDirectChannelStateChanged(_ notification: Notification) {
        //print("FCM Direct Channel Established: \(Messaging.messaging().isDirectChannelEstablished)")
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
}

extension Dictionary {
    /// Utility method for printing Dictionaries as pretty-printed JSON.
    var jsonString: String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
extension Data {
    // Print Data as a string of bytes in hex, such as the common representation of APNs device tokens
    // See: http://stackoverflow.com/a/40031342/9849
    var hexByteString: String {
        return self.map { String(format: "%02.2hhx", $0) }.joined()
    }
}


extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy/MM/dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()
    static let shortiso8601 : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    var shortiso8601: String {
        return Formatter.shortiso8601.string(from: self)
    }
}
extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
    var shortdateFromISO8601 : Date? {
        return Formatter.shortiso8601.date(from: self)
    }
}
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleToFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
