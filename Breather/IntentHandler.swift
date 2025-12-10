import Intents

class IntentHandler: INExtension, BreathingExerciseIntentHandling {
    
    func handle(intent: BreathingExerciseIntent, completion: @escaping (BreathingExerciseIntentResponse) -> Void) {
        
        let app = intent.appName
        let appName = displayName(for: app)
        
        // Vérification du mode strict
        let strictModeManager = StrictModeManager.shared
        if strictModeManager.isAppBlockedInStrictMode(appName: appName) {
            // Mode strict activé : blocage total, pas de bypass
            let activity = NSUserActivity(activityType: "com.breather.exercise")
            activity.userInfo = [
                "appName": appName,
                "duration": 0.0,  // Durée 0 = mode strict (affichage différent)
                "strictMode": true
            ]
            
            let response = BreathingExerciseIntentResponse(code: .continueInApp, userActivity: activity)
            completion(response)
            return
        }
        
        // Utilise la durée configurée dans Raccourcis, sinon durée par défaut de l'app
        let duration: Double
        if let intentDuration = intent.duration {
            duration = intentDuration.doubleValue  // Duration en secondes
        } else {
            duration = durationForApp(app)
        }
        
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
        activity.userInfo = [
            "appName": appName,
            "duration": duration,
            "strictMode": false
        ]
        
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
    
    // Durées personnalisées par application
    private func durationForApp(_ app: TargetApp) -> Double {
        switch app {
        case .tiktok: return 30.0      // TikTok = le plus addictif, durée longue
        case .instagram: return 20.0   // Instagram = très addictif
        case .twitter: return 15.0     // X/Twitter = scroll infini
        case .facebook: return 20.0    // Facebook = très addictif
        case .youtube: return 10.0     // YouTube = souvent intentionnel
        case .reddit: return 25.0      // Reddit = rabbit hole géant
        case .linkedin: return 5.0     // LinkedIn = professionnel, OK
        case .snapchat: return 8.0     // Snapchat = messages, moins addictif
        case .whatsapp: return 3.0     // WhatsApp = messaging essentiel
        case .messenger: return 3.0    // Messenger = messaging essentiel
        case .unknown: return 10.0     // Par défaut
        }
    }
}
