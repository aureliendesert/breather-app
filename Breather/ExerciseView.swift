import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct ExerciseView: View {
    
    @EnvironmentObject var state: ExerciseState
    @StateObject var statsManager = StatsManager.shared

    
    @State private var breathProgress: CGFloat = 0
    @State private var imageScale: CGFloat = 2.0
    @State private var showContent = false
    
    // Durées dynamiques basées sur l'état
    private var breathInDuration: Double {
        state.breathDuration
    }
    private var breathOutDuration: Double {
        state.breathDuration
    }
    private let maxScale: CGFloat = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showContent {
                    contentView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                }
                

                Image("BreathingImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 1500)
                    .scaleEffect(imageScale)
                    .position(
                        x: geometry.size.width / 2,
                        y: imageYPosition(in: geometry)
                    )
                    .zIndex(-1)

                if !showContent {
                    VStack {
                        Text("Pitié respire un peu")
                            .font(.custom("PMackinacProMedium", size: 32))
                            .foregroundStyle(Color(hex: 0xFCF2D7))
                        
                        Text("Touche de l'herbe, fais des mots croisés jsp mais fais quelque chose bordel")
                            .font(.custom("PMackinacProMedium", size: 20))
                            .multilineTextAlignment(.center)
                            .padding(24)
                            .lineSpacing(8)
                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            resetState()
            startBreathingExercise()
        }
        .onReceive(NotificationCenter.default.publisher(for: .exerciseDidStart)) { _ in
            resetState()
            startBreathingExercise()
        }
        .background(Color(hex: 0x030302))
    }
    
    private func resetState() {
        breathProgress = 0
        imageScale = 2.0
        showContent = false
    }
    
    private func imageYPosition(in geometry: GeometryProxy) -> CGFloat {
        let totalHeight = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
        
        let startY = totalHeight + 100
        let endY: CGFloat = -100
        
        return startY + (endY - startY) * breathProgress
    }
    
    private var contentView: some View {
        VStack(spacing: 80) {
            Spacer()
            
            Text("Maintenant qu'est-ce qu'on fait?")
                .font(.custom("P22MackinacProBook", size: 32))
                .multilineTextAlignment(.center)
                .lineSpacing(12)
                .foregroundStyle(Color(hex: 0xFCF2D7))
            
            
            VStack(spacing: 24) {
                if statsManager.todayAttempts >= 1 {
                    Text("Ça fait déjà \(statsManager.todayAttempts) fois que tu vas sur \(state.appName) aujourd'hui...")
                        .font(.custom("PMackinacProMedium", size: 20))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                } else {
                    Text("Il est vrai que tu n'as pas encore ouvert Instagram aujourd'hui...")
                        .font(.custom("PMackinacProMedium", size: 20))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                }
                
                if let lastOpened = statsManager.timeSinceLastOpened(for: state.appName) {
                    Text("La dernière fois c'était il y a \(lastOpened)")
                        .font(.custom("PMackinacProMedium", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                }
            }
            
            VStack(spacing: 16) {
                if state.isStrictMode {
                    // Mode strict : un seul bouton
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(Color.red)
                            Text("Mode Strict Activé")
                                .font(.custom("P22MackinacPro-Bold", size: 16))
                                .foregroundStyle(Color.red)
                        }
                        .padding(.bottom, 8)
                        
                        if let rule = StrictModeManager.shared.activeRule(for: state.appName) {
                            Text("Cette app est bloquée jusqu'à \(String(format: "%02d:%02d", rule.endHour, rule.endMinute))")
                                .font(.custom("PMackinacProMedium", size: 14))
                                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Retourner à l'accueil") {
                            HapticsManager.shared.playSuccess()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                state.complete(openApp: false)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
                        .bold()
                        .foregroundStyle(Color(hex: 0x030302))
                        .background(Color(hex: 0xFCF2D7))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .font(.custom("P22MackinacPro-Bold", size: 14))
                    }
                } else {
                    // Mode normal : deux boutons
                    Button("Résister à la tentation") {
                        HapticsManager.shared.playSuccess()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            state.complete(openApp: false)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
                    .bold()
                    .foregroundStyle(Color(hex: 0x030302))
                    .background(Color(hex: 0xFCF2D7))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .font(.custom("P22MackinacPro-Bold", size: 14))
                    
                    Button("Ok pour cette fois...") {
                        HapticsManager.shared.playTap()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            state.complete(openApp: true)
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.custom("P22MackinacPro-Bold", size: 14))
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                }
            }
            .padding(.bottom, 32)
        }
    }
    
    private func startBreathingExercise() {
        // Play blocked haptic immediately
        HapticsManager.shared.playBlocked()
        
        // Mode strict : pas d'animation, affiche direct le contenu
        if state.isStrictMode || breathInDuration == 0 {
            withAnimation(.easeIn(duration: 0.3)) {
                showContent = true
            }
            return
        }
        
        // Mode normal : animation de respiration
        // Breath in - image rises from bottom to top, scales up then down
        withAnimation(.easeInOut(duration: breathInDuration)) {
            breathProgress = 1.0
        }
        
        // Scale up during first half, scale down during second half
        withAnimation(.easeIn(duration: breathInDuration / 2)) {
            imageScale = maxScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + breathInDuration / 2) {
            withAnimation(.easeOut(duration: breathInDuration / 2)) {
                imageScale = 2.0
            }
        }
        
        // After breath in complete, show content
        DispatchQueue.main.asyncAfter(deadline: .now() + breathInDuration) {
            withAnimation(.easeIn(duration: 0.3)) {
                showContent = true
            }
        }
    }
}

#Preview {
    ExerciseView()
        .environmentObject(ExerciseState.shared)
}
