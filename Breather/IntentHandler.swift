import Intents

class IntentHandler: INExtension, BreathingExerciseIntentHandling {
    
    func handle(intent: BreathingExerciseIntent, completion: @escaping (BreathingExerciseIntentResponse) -> Void) {
        
        let app = intent.appName
        let appName = displayName(for: app)
        
        // Check if we should skip
        let key = "allowed_\(appName)"
        let lastAllowed = UserDefaults.standard.double(forKey: key)
        let shouldSkip = lastAllowed > 0 && (Date().timeIntervalSince1970 - lastAllowed) < 5
        
        if shouldSkip {
            let response = BreathingExerciseIntentResponse(code: .success, userActivity: nil)
            response.shouldOpenApp = true as NSNumber
            completion(response)
            return
        }
        
        // Need to show UI - continue in app
        let activity = NSUserActivity(activityType: "com.breather.exercise")
        activity.userInfo = ["appName": appName]
        
        let response = BreathingExerciseIntentResponse(code: .continueInApp, userActivity: activity)
        completion(response)
    }
    
    func resolveAppName(for intent: BreathingExerciseIntent, with completion: @escaping (TargetAppResolutionResult) -> Void) {
        let app = intent.appName
        if app == .unknown {
            completion(.needsValue())
        } else {
            completion(.success(with: app))
        }
    }
    
    private func displayName(for app: TargetApp) -> String {
        switch app {
        case .instagram: return "Instagram"
        case .twitter: return "X (Twitter)"
        case .tiktok: return "TikTok"
        case .facebook: return "Facebook"
        case .youtube: return "YouTube"
        case .reddit: return "Reddit"
        case .linkedin: return "LinkedIn"
        case .snapchat: return "Snapchat"
        case .whatsapp: return "WhatsApp"
        case .messenger: return "Messenger"
        case .unknown: return "App"
        }
    }
}
