import UIKit
import UserNotifications
import Firebase  // Add Firebase import

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Test Firestore connection
        let db = Firestore.firestore()
        db.collection("test").addDocument(data: ["test": "data"]) { error in
            if let error = error {
                print("Firestore test failed: \(error)")
            } else {
                print("Firestore test succeeded.")
            }
        }

        return true
    }


    // Handle notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
