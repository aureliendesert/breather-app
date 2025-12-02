import SwiftUI

@MainActor
class ExerciseState: ObservableObject {
    
    static let shared = ExerciseState()
    
    @Published var isActive = false
    @Published var appName = ""
    var urlScheme: String?
    
    private var continuation: CheckedContinuation<Bool, Never>?
    
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
    }
    
    func complete(openApp: Bool) {
        if openApp {
            // Save timestamp to skip next time
            let key = "allowed_\(appName)"
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)
            
            // Open the app
            if let scheme = urlScheme, let url = URL(string: scheme) {
                UIApplication.shared.open(url)
            }
        }
        
        isActive = false
        appName = ""
        urlScheme = nil
    }
}
