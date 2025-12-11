import SwiftUI

struct StrictModeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var strictModeManager = StrictModeManager.shared
    @State private var showingAddRule = false
    
    var body: some View {
        ZStack {
            Color(hex: 0x030302)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Fermer")
                            .font(.custom("PMackinacProMedium", size: 16))
                            .foregroundStyle(Color(hex: 0xFCF2D7))
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Mode Strict")
                        .font(.custom("PMackinacProMedium", size: 20))
                        .foregroundStyle(Color(hex: 0xFCF2D7))
                    
                    Spacer()
                    
                    if strictModeManager.isStrictModeEnabled {
                        Button(action: { showingAddRule = true }) {
                            Text("Ajouter")
                                .font(.custom("PMackinacProMedium", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                        }
                        .frame(width: 100, alignment: .trailing)
                    } else {
                        Text("Ajouter")
                            .font(.custom("PMackinacProMedium", size: 16))
                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.3))
                            .frame(width: 100, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Toggle du mode strict global
                        VStack(spacing: 16) {
                            Toggle(isOn: Binding(
                                get: { strictModeManager.isStrictModeEnabled },
                                set: { _ in strictModeManager.toggleStrictMode() }
                            )) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Activer le mode strict")
                                        .font(.custom("PMackinacProMedium", size: 18))
                                        .foregroundStyle(Color(hex: 0xFCF2D7))
                                    
                                    Text("Bloquer les apps pendant certaines heures")
                                        .font(.custom("PMackinacProMedium", size: 14))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: 0xFCF2D7)))
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
            }
        }
        .sheet(isPresented: $showingAddRule) {
            AddRuleView()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Aucune règle de blocage")
                .font(.custom("PMackinacProMedium", size: 24))
                .foregroundStyle(Color(hex: 0xFCF2D7))
            
            Text("Appuyez sur Ajouter pour créer une règle")
                .font(.custom("PMackinacProMedium", size: 16))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
            
            Spacer()
        }
        .padding()
    }
    
    private var rulesListView: some View {
        VStack(spacing: 16) {
            ForEach(strictModeManager.rules) { rule in
                RuleRowView(rule: rule)
            }
        }
        .padding()
    }
}

struct RuleRowView: View {
    let rule: BlockingRule
    @StateObject var strictModeManager = StrictModeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Info de l'app et horaire
            VStack(alignment: .leading, spacing: 8) {
                Text(rule.appName)
                    .font(.custom("PMackinacProMedium", size: 20))
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                
                Text(rule.timeRangeDescription)
                    .font(.custom("PMackinacProMedium", size: 16))
                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                
                if rule.isCurrentlyBlocked() {
                    Text("🔴 Bloqué maintenant")
                        .font(.custom("PMackinacProMedium", size: 14))
                        .foregroundStyle(Color.red)
                } else {
                    Text("Inactif")
                        .font(.custom("PMackinacProMedium", size: 14))
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
        .background(Color(hex: 0xFCF2D7, alpha: 0.05))
        .cornerRadius(8)
        .contextMenu {
            Button(role: .destructive) {
                strictModeManager.deleteRule(rule)
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
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
    
    let availableApps = ["Instagram", "TikTok", "X (Twitter)", "Facebook", "YouTube", "Reddit", "LinkedIn", "Snapchat", "WhatsApp", "Messenger"]
    
    var body: some View {
        ZStack {
            Color(hex: 0x030302)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Annuler") {
                        dismiss()
                    }
                    .font(.custom("PMackinacProMedium", size: 16))
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                    .frame(width: 100, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Nouvelle règle")
                        .font(.custom("PMackinacProMedium", size: 20))
                        .foregroundStyle(Color(hex: 0xFCF2D7))
                    
                    Spacer()
                    
                    Button("Créer") {
                        addRule()
                    }
                    .font(.custom("PMackinacProMedium", size: 16))
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                    .frame(width: 100, alignment: .trailing)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Sélection de l'app
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Application")
                                .font(.custom("PMackinacProMedium", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            Picker("Application", selection: $selectedApp) {
                                ForEach(availableApps, id: \.self) { app in
                                    Text(app)
                                        .font(.custom("PMackinacProMedium", size: 18))
                                        .tag(app)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                        }
                        
                        // Règles prédéfinies
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Règles prédéfinies")
                                .font(.custom("PMackinacProMedium", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            VStack(spacing: 12) {
                                PresetButton(title: "Heures de travail (9h-17h)") {
                                    startHour = 9
                                    startMinute = 0
                                    endHour = 17
                                    endMinute = 0
                                }
                                
                                PresetButton(title: "Nuit (22h-7h)") {
                                    startHour = 22
                                    startMinute = 0
                                    endHour = 7
                                    endMinute = 0
                                }
                                
                                PresetButton(title: "Matin (6h-9h)") {
                                    startHour = 6
                                    startMinute = 0
                                    endHour = 9
                                    endMinute = 0
                                }
                                
                                PresetButton(title: "Toute la journée (24/7)") {
                                    startHour = 0
                                    startMinute = 0
                                    endHour = 23
                                    endMinute = 59
                                }
                            }
                        }
                        
                        // Personnalisation des heures
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ou personnaliser")
                                .font(.custom("PMackinacProMedium", size: 16))
                                .foregroundStyle(Color(hex: 0xFCF2D7))
                            
                            HStack(spacing: 32) {
                                // Heure de début
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Début")
                                        .font(.custom("PMackinacProMedium", size: 14))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                                    
                                    HStack(spacing: 8) {
                                        Picker("Heure", selection: $startHour) {
                                            ForEach(0..<24) { hour in
                                                Text(String(format: "%02d", hour))
                                                    .font(.custom("PMackinacProMedium", size: 18))
                                                    .tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60, height: 100)
                                        
                                        Text(":")
                                            .font(.custom("PMackinacProMedium", size: 24))
                                            .foregroundStyle(Color(hex: 0xFCF2D7))
                                        
                                        Picker("Minute", selection: $startMinute) {
                                            ForEach(0..<60) { minute in
                                                Text(String(format: "%02d", minute))
                                                    .font(.custom("PMackinacProMedium", size: 18))
                                                    .tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60, height: 100)
                                    }
                                }
                                
                                // Heure de fin
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Fin")
                                        .font(.custom("PMackinacProMedium", size: 14))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                                    
                                    HStack(spacing: 8) {
                                        Picker("Heure", selection: $endHour) {
                                            ForEach(0..<24) { hour in
                                                Text(String(format: "%02d", hour))
                                                    .font(.custom("PMackinacProMedium", size: 18))
                                                    .tag(hour)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60, height: 100)
                                        
                                        Text(":")
                                            .font(.custom("PMackinacProMedium", size: 24))
                                            .foregroundStyle(Color(hex: 0xFCF2D7))
                                        
                                        Picker("Minute", selection: $endMinute) {
                                            ForEach(0..<60) { minute in
                                                Text(String(format: "%02d", minute))
                                                    .font(.custom("PMackinacProMedium", size: 18))
                                                    .tag(minute)
                                            }
                                        }
                                        .pickerStyle(.wheel)
                                        .frame(width: 60, height: 100)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("PMackinacProMedium", size: 16))
                .foregroundStyle(Color(hex: 0x030302))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: 0xFCF2D7))
                .cornerRadius(8)
        }
    }
}

#Preview {
    StrictModeView()
}
