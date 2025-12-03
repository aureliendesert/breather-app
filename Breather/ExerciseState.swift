import SwiftUI

@MainActor
class ExerciseState: ObservableObject {
    
    static let shared = ExerciseState()
    
    @Published var isActive = false
    @Published var appName = ""
    var urlScheme: String?
    
    // Map of app names to URL schemes
    private let appSchemes: [String: String] = [
        "Instagram": "instagram://",
        "Twitter": "twitter://",
        "X": "twitter://",
        "TikTok": "tiktok://",
        "Facebook": "fb://",
        "YouTube": "youtube://",
        "Reddit": "reddit://",
        "LinkedIn": "linkedin://",
        "Snapchat": "snapchat://",
        "WhatsApp": "whatsapp://",
        "Messenger": "fb-messenger://"
    ]
    
    func startExercise(appName: String) {
        self.appName = appName
        self.urlScheme = appSchemes[appName]
        self.isActive = true
        
        // Notify that a new exercise started (for resetting view state)
        NotificationCenter.default.post(name: .exerciseDidStart, object: nil)
    }
    
    func complete(openApp: Bool) {
        // Record the attempt
        StatsManager.shared.recordAttempt(opened: openApp, appName: appName)
        
        if openApp {
            // Save timestamp to skip next time
            let key = "allowed_\(appName)"
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)
            
            // Open the app
            if let scheme = urlScheme, let url = URL(string: scheme) {
                UIApplication.shared.open(url)
            }
        } else {
            // "I'm good" - go to home screen
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
        
        isActive = false
        appName = ""
        urlScheme = nil
    }
}

extension Notification.Name {
    static let exerciseDidStart = Notification.Name("exerciseDidStart")
}
