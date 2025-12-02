import SwiftUI
import Intents

@main
struct BreatherApp: App {
    
    @StateObject private var exerciseState = ExerciseState.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(exerciseState)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var exerciseState: ExerciseState
    
    var body: some View {
        if exerciseState.isActive {
            ExerciseView()
        } else {
            Text("Breather")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
        print("handlerFor intent called: \(type(of: intent))")
        if intent is BreathingExerciseIntent {
            return IntentHandler()
        }
        return nil
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("Scene received userActivity: \(userActivity.activityType)")
        handleUserActivity(userActivity)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("Scene willConnectTo called")
        
        if let userActivity = connectionOptions.userActivities.first {
            print("Found userActivity in connectionOptions: \(userActivity.activityType)")
            handleUserActivity(userActivity)
        }
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        print("Handling activity: \(userActivity.activityType)")
        
        // First try to get appName from userInfo (we put it there as a String)
        if let appName = userActivity.userInfo?["appName"] as? String {
            print("Found appName in userInfo: \(appName)")
            Task { @MainActor in
                ExerciseState.shared.startExercise(appName: appName)
            }
            return
        }
        
        // Fallback: get from intent and convert to string
        if let intent = userActivity.interaction?.intent as? BreathingExerciseIntent {
            let appName = displayName(for: intent.appName)
            print("Found appName from intent: \(appName)")
            Task { @MainActor in
                ExerciseState.shared.startExercise(appName: appName)
            }
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
