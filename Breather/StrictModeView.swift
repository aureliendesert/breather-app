import SwiftUI

struct StrictModeView: View {
    @StateObject var strictModeManager = StrictModeManager.shared
    @State private var showingAddRule = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x030302)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Toggle du mode strict global
                    VStack(spacing: 16) {
                        Toggle(isOn: Binding(
                            get: { strictModeManager.isStrictModeEnabled },
                            set: { _ in strictModeManager.toggleStrictMode() }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mode Strict")
                                    .font(.custom("P22MackinacPro-Bold", size: 20))
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                                
                                Text("Bloquer les apps pendant certaines heures")
                                    .font(.custom("PMackinacProMedium", size: 14))
                                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: 0xFCF2D7)))
                        .padding()
                        .background(Color(hex: 0xFCF2D7, alpha: 0.1))
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    if strictModeManager.isStrictModeEnabled {
                        // Liste des règles
                        if strictModeManager.rules.isEmpty {
                            emptyStateView
                        } else {
                            rulesListView
                        }
                    }
                }
            }
            .navigationTitle("Mode Strict")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if strictModeManager.isStrictModeEnabled {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddRule = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddRule) {
                AddRuleView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "clock.badge.xmark")
                .font(.system(size: 64))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.3))
            
            Text("Aucune règle de blocage")
                .font(.custom("P22MackinacProBook", size: 24))
                .foregroundStyle(Color(hex: 0xFCF2D7))
            
            Text("Appuyez sur + pour ajouter une règle")
                .font(.custom("PMackinacProMedium", size: 16))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
            
            Spacer()
        }
        .padding()
    }
    
    private var rulesListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(strictModeManager.rules) { rule in
                    RuleRowView(rule: rule)
                }
            }
            .padding()
        }
    }
}

struct RuleRowView: View {
    let rule: BlockingRule
    @StateObject var strictModeManager = StrictModeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône de l'app
            VStack(spacing: 4) {
                Text(appEmoji(for: rule.appName))
                    .font(.system(size: 32))
                
                Text(rule.appName)
                    .font(.custom("PMackinacProMedium", size: 12))
                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
            }
            .frame(width: 80)
            
            // Plage horaire
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.timeRangeDescription)
                    .font(.custom("P22MackinacPro-Bold", size: 18))
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                
                if rule.isCurrentlyBlocked() {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text("Bloqué maintenant")
                            .font(.custom("PMackinacProMedium", size: 12))
                            .foregroundStyle(Color.red)
                    }
                } else {
                    Text("Inactif")
                        .font(.custom("PMackinacProMedium", size: 12))
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { _ in strictModeManager.toggleRule(rule) }
            ))
            .toggleStyle(SwitchToggleStyle(tint: Color(hex: 0xFCF2D7)))
            .labelsHidden()
        }
        .padding()
        .background(Color(hex: 0xFCF2D7, alpha: 0.1))
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                strictModeManager.deleteRule(rule)
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }
    
    private func appEmoji(for appName: String) -> String {
        switch appName {
        case "Instagram": return "📷"
        case "TikTok": return "🎵"
        case "X (Twitter)": return "🐦"
        case "Facebook": return "👥"
        case "YouTube": return "📺"
        case "Reddit": return "🤓"
        case "LinkedIn": return "💼"
        case "Snapchat": return "👻"
        case "WhatsApp": return "💬"
        case "Messenger": return "💬"
        default: return "📱"
        }
    }
}

struct AddRuleView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var strictModeManager = StrictModeManager.shared
    
    @State private var selectedApp = "Instagram"
    @State private var startHour = 22
    @State private var startMinute = 0
    @State private var endHour = 7
    @State private var endMinute = 0
    @State private var showPresets = false
    
    let availableApps = ["Instagram", "TikTok", "X (Twitter)", "Facebook", "YouTube", "Reddit", "LinkedIn", "Snapchat", "WhatsApp", "Messenger"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x030302)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Sélection de l'app
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Application")
                                .font(.custom("P22MackinacPro-Bold", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            Picker("Application", selection: $selectedApp) {
                                ForEach(availableApps, id: \.self) { app in
                                    Text(app).tag(app)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                        }
                        
                        // Règles prédéfinies
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Règles prédéfinies")
                                .font(.custom("P22MackinacPro-Bold", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    PresetButton(title: "Heures de travail", subtitle: "9h-17h") {
                                        startHour = 9
                                        startMinute = 0
                                        endHour = 17
                                        endMinute = 0
                                    }
                                    
                                    PresetButton(title: "Nuit", subtitle: "22h-7h") {
                                        startHour = 22
                                        startMinute = 0
                                        endHour = 7
                                        endMinute = 0
                                    }
                                    
                                    PresetButton(title: "Matin", subtitle: "6h-9h") {
                                        startHour = 6
                                        startMinute = 0
                                        endHour = 9
                                        endMinute = 0
                                    }
                                    
                                    PresetButton(title: "24/7", subtitle: "Toujours") {
                                        startHour = 0
                                        startMinute = 0
                                        endHour = 23
                                        endMinute = 59
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Personnalisation des heures
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Personnaliser")
                                .font(.custom("P22MackinacPro-Bold", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            HStack(spacing: 16) {
                                // Heure de début
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Début")
                                        .font(.custom("PMackinacProMedium", size: 14))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                                    
                                    HStack {
                                        Picker("Heure", selection: $startHour) {
                                            ForEach(0..<24) { hour in
                                                Text(String(format: "%02d", hour)).tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60)
                                        
                                        Text(":")
                                            .font(.custom("P22MackinacPro-Bold", size: 24))
                                            .foregroundStyle(Color(hex: 0xFCF2D7))
                                        
                                        Picker("Minute", selection: $startMinute) {
                                            ForEach(0..<60) { minute in
                                                Text(String(format: "%02d", minute)).tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60)
                                    }
                                }
                                
                                // Heure de fin
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Fin")
                                        .font(.custom("PMackinacProMedium", size: 14))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                                    
                                    HStack {
                                        Picker("Heure", selection: $endHour) {
                                            ForEach(0..<24) { hour in
                                                Text(String(format: "%02d", hour)).tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60)
                                        
                                        Text(":")
                                            .font(.custom("P22MackinacPro-Bold", size: 24))
                                            .foregroundStyle(Color(hex: 0xFCF2D7))
                                        
                                        Picker("Minute", selection: $endMinute) {
                                            ForEach(0..<60) { minute in
                                                Text(String(format: "%02d", minute)).tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60)
                                    }
                                }
                            }
                        }
                        
                        // Bouton de création
                        Button(action: addRule) {
                            Text("Créer la règle")
                                .font(.custom("P22MackinacPro-Bold", size: 16))
                                .foregroundStyle(Color(hex: 0x030302))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: 0xFCF2D7))
                                .cornerRadius(12)
                        }
                        .padding(.top, 24)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nouvelle règle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                }
            }
        }
    }
    
    private func addRule() {
        let rule = BlockingRule(
            appName: selectedApp,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute
        )
        strictModeManager.addRule(rule)
        dismiss()
    }
}

struct PresetButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.custom("P22MackinacPro-Bold", size: 14))
                    .foregroundStyle(Color(hex: 0x030302))
                
                Text(subtitle)
                    .font(.custom("PMackinacProMedium", size: 12))
                    .foregroundStyle(Color(hex: 0x030302, alpha: 0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: 0xFCF2D7))
            .cornerRadius(8)
        }
    }
}

#Preview {
    StrictModeView()
}
