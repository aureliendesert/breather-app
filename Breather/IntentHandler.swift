//
//  IntentHandler.swift
//  Breather
//
//  Created by Gaëtan Jestin on 02/12/2025.
//

import Intents

class IntentHandler: INExtension, BreathingExerciseIntentHandling {
    
    func handle(intent: BreathingExerciseIntent, completion: @escaping (BreathingExerciseIntentResponse) -> Void) {
        
        let appName = intent.appName ?? "App"
        
        // Check if we should skip
        let key = "allowed_\(appName)"
        let lastAllowed = UserDefaults.standard.double(forKey: key)
        let shouldSkip = lastAllowed > 0 && (Date().timeIntervalSince1970 - lastAllowed) < 5
        
        if shouldSkip {
            // Skip - return success with shouldOpenApp = true
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
    
    func resolveAppName(for intent: BreathingExerciseIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let appName = intent.appName, !appName.isEmpty {
            completion(.success(with: appName))
        } else {
            completion(.needsValue())
        }
    }
}
