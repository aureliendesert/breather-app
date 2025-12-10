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
    @StateObject var statsManager = StatsManager.shared
    @State private var showStrictMode = false
    
    var body: some View {
        if exerciseState.isActive {
            ExerciseView()
        } else {
            GeometryReader { geometry in
                ZStack {
                    Image("BreathingImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 800)
                        .scaleEffect(5)
                        .position(
                            x: geometry.size.width / 2,
                            y: -100
                        )
                    
                    
                    VStack() {
                        Text("Breather")
                            .font(.custom("PMackinacProMedium", size: 64))
                            .foregroundStyle(Color(hex: 0xFCF2D7))
                        
                        Spacer()
                            .frame(height: 96)
                        
                        VStack(spacing: 8) {
                            Text("\(statsManager.todayAttempts)")
                                .font(.custom("PMackinacProMedium", size: 64))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            Text("Tentatives d’ouvertures aujourd’hui")
                                .font(.custom("PMackinacProMedium", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                            
                            Spacer()
                                .frame(height: 32)
                            
                            Text("\(statsManager.todayBlocked)")
                                .font(.custom("PMackinacProMedium", size: 64))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            Text("D’entre elles ont été bloquées")
                                .font(.custom("PMackinacProMedium", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                        }
                    }
                    
                    // Lien Mode Strict positionné en bas (VStack séparé dans le ZStack)
                    VStack {
                        Spacer()
                        
                        Button(action: { showStrictMode = true }) {
                            Text("Mode strict")
                                .font(.custom("PMackinacProMedium", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                .underline()
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .sheet(isPresented: $showStrictMode) {
                StrictModeView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ExerciseState.shared)
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Warm up haptics engine
        HapticsManager.shared.prepare()
        return true
    }
    
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
        
//        for family in UIFont.familyNames {
//            print("Family: \(family)")
//            for name in UIFont.fontNames(forFamilyName: family) {
//                print("   \(name)")
//            }
//        }
        
        if let userActivity = connectionOptions.userActivities.first {
            print("Found userActivity in connectionOptions: \(userActivity.activityType)")
            handleUserActivity(userActivity)
        }
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        print("Handling activity: \(userActivity.activityType)")
        
        // Extract duration from userInfo (default to 8.0 if not provided)
        let duration = userActivity.userInfo?["duration"] as? Double ?? 8.0
        let strictMode = userActivity.userInfo?["strictMode"] as? Bool ?? false
        
        // First try to get appName from userInfo (we put it there as a String)
        if let appName = userActivity.userInfo?["appName"] as? String {
            print("Found appName in userInfo: \(appName), duration: \(duration), strictMode: \(strictMode)")
            Task { @MainActor in
                ExerciseState.shared.startExercise(appName: appName, duration: duration, strictMode: strictMode)
            }
            return
        }
        
        // Fallback: get from intent and convert to string
        if let intent = userActivity.interaction?.intent as? BreathingExerciseIntent {
            let appName = displayName(for: intent.appName)
            print("Found appName from intent: \(appName), duration: \(duration), strictMode: \(strictMode)")
            Task { @MainActor in
                ExerciseState.shared.startExercise(appName: appName, duration: duration, strictMode: strictMode)
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
