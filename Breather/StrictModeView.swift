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
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Retour")
                        }
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
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                Text("Ajouter")
                            }
                            .font(.custom("PMackinacProMedium", size: 16))
                            .foregroundStyle(Color(hex: 0xFCF2D7))
                        }
                        .frame(width: 100, alignment: .trailing)
                    } else {
                        Spacer()
                            .frame(width: 100)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color(hex: 0x030302))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Toggle du mode strict global avec meilleur design
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "shield.lefthalf.filled")
                                            .font(.system(size: 20))
                                            .foregroundStyle(strictModeManager.isStrictModeEnabled ? Color.green : Color(hex: 0xFCF2D7, alpha: 0.5))
                                        
                                        Text("Mode strict")
                                            .font(.custom("PMackinacProMedium", size: 20))
                                            .foregroundStyle(Color(hex: 0xFCF2D7))
                                    }
                                    
                                    Text("Bloquez les apps pendant certaines heures de la journée")
                                        .font(.custom("PMackinacProMedium", size: 14))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                                
                                Toggle(isOn: Binding(
                                    get: { strictModeManager.isStrictModeEnabled },
                                    set: { _ in 
                                        withAnimation(.spring(response: 0.3)) {
                                            strictModeManager.toggleStrictMode()
                                        }
                                    }
                                )) {
                                    EmptyView()
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                                .labelsHidden()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: 0xFCF2D7, alpha: 0.06))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        if strictModeManager.isStrictModeEnabled {
                            // Liste des règles
                            if strictModeManager.rules.isEmpty {
                                emptyStateView
                            } else {
                                rulesListView
                            }
                        } else {
                            // État désactivé
                            disabledStateView
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddRule) {
            AddRuleView()
        }
    }
    
    private var disabledStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "moon.zzz")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.3))
            
            Text("Mode strict désactivé")
                .font(.custom("PMackinacProMedium", size: 24))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
            
            Text("Activez le mode strict ci-dessus pour commencer à créer des règles de blocage")
                .font(.custom("PMackinacProMedium", size: 16))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.4))
            
            Text("Aucune règle")
                .font(.custom("PMackinacProMedium", size: 26))
                .foregroundStyle(Color(hex: 0xFCF2D7))
            
            Text("Créez votre première règle de blocage pour commencer")
                .font(.custom("PMackinacProMedium", size: 16))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingAddRule = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Créer une règle")
                        .font(.custom("PMackinacProMedium", size: 16))
                }
                .foregroundStyle(Color(hex: 0x030302))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(hex: 0xFCF2D7))
                .cornerRadius(12)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding()
    }
    
    private var rulesListView: some View {
        VStack(spacing: 0) {
            // Header de la section avec compteur
            HStack {
                Text("Mes règles")
                    .font(.custom("PMackinacProMedium", size: 18))
                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                
                Text("(\(strictModeManager.rules.count))")
                    .font(.custom("PMackinacProMedium", size: 16))
                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                
                Spacer()
                
                // Indicateur de règles actives
                let activeCount = strictModeManager.rules.filter { $0.isCurrentlyBlocked() }.count
                if activeCount > 0 {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("\(activeCount) active\(activeCount > 1 ? "s" : "")")
                            .font(.custom("PMackinacProMedium", size: 14))
                            .foregroundStyle(Color.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Liste des règles
            VStack(spacing: 12) {
                ForEach(strictModeManager.rules) { rule in
                    RuleRowView(rule: rule)
                }
            }
            .padding(.horizontal, 20)
        }
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
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                    
                    Text(rule.timeRangeDescription)
                        .font(.custom("PMackinacProMedium", size: 16))
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                }
                
                HStack(spacing: 8) {
                    if rule.isCurrentlyBlocked() {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("Actif maintenant")
                            .font(.custom("PMackinacProMedium", size: 14))
                            .foregroundStyle(Color.red)
                    } else {
                        Circle()
                            .fill(Color(hex: 0xFCF2D7, alpha: 0.3))
                            .frame(width: 8, height: 8)
                        Text("En attente")
                            .font(.custom("PMackinacProMedium", size: 14))
                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                    }
                }
            }
            
            Spacer()
            
            // Bouton supprimer visible
            Button(action: {
                withAnimation {
                    strictModeManager.deleteRule(rule)
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red.opacity(0.8))
                    .frame(width: 44, height: 44)
            }
            
            // Toggle
            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { _ in 
                    withAnimation {
                        strictModeManager.toggleRule(rule)
                    }
                }
            ))
            .toggleStyle(SwitchToggleStyle(tint: Color(hex: 0xFCF2D7)))
            .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(rule.isEnabled ? Color(hex: 0xFCF2D7, alpha: 0.08) : Color(hex: 0xFCF2D7, alpha: 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            rule.isCurrentlyBlocked() ? Color.red.opacity(0.5) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
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
    @State private var selectedPreset: PresetType? = nil
    @State private var isUpdatingFromPreset = false  // Flag pour éviter la réinitialisation
    
    let availableApps = ["Instagram", "TikTok", "X (Twitter)", "Facebook", "YouTube", "Reddit", "LinkedIn", "Snapchat", "WhatsApp", "Messenger"]
    
    enum PresetType: String, Equatable {
        case night = "Nuit complète"
        case work = "Heures de travail"
        case morning = "Routine matinale"
        case allDay = "Blocage total"
    }
    
    var body: some View {
        ZStack {
            Color(hex: 0x030302)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header avec plus d'espace
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 20)
                    
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
                        .bold()
                        .foregroundStyle(Color(hex: 0x030302))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: 0xFCF2D7))
                        .cornerRadius(8)
                        .frame(width: 100, alignment: .trailing)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    Spacer()
                        .frame(height: 12)
                }
                .background(Color(hex: 0x030302))
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Sélection de l'app
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "app.badge")
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                                    .font(.system(size: 18))
                                
                                Text("Application à bloquer")
                                    .font(.custom("PMackinacProMedium", size: 18))
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                            }
                            .padding(.horizontal)
                            
                            Picker("Application", selection: $selectedApp) {
                                ForEach(availableApps, id: \.self) { app in
                                    Text(app)
                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                        .font(.custom("PMackinacProMedium", size: 18))
                                        .tag(app)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                            .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                            .cornerRadius(12)
                            .colorScheme(.dark)
                        }
                        
                        Divider()
                            .background(Color(hex: 0xFCF2D7, alpha: 0.2))
                            .padding(.horizontal)
                        
                        // NOUVEAU : Personnalisation en PREMIER
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Image(systemName: "clock.arrow.2.circlepath")
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                                    .font(.system(size: 18))
                                
                                Text("Définir les horaires")
                                    .font(.custom("PMackinacProMedium", size: 18))
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                            }
                            .padding(.horizontal)
                            
                            // Sélecteurs d'horaires - TOUJOURS VISIBLES
                            VStack(spacing: 16) {
                                HStack(spacing: 20) {
                                    // Heure de début
                                    VStack(alignment: .center, spacing: 12) {
                                        Text("Début")
                                            .font(.custom("PMackinacProMedium", size: 15))
                                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                        
                                        HStack(spacing: 4) {
                                            Picker("Heure", selection: $startHour) {
                                                ForEach(0..<24) { hour in
                                                    Text(String(format: "%02d", hour))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 20))
                                                        .tag(hour)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 70, height: 120)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: startHour) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                            
                                            Text(":")
                                                .font(.custom("PMackinacProMedium", size: 28))
                                                .foregroundStyle(Color(hex: 0xFCF2D7))
                                                .offset(y: -2)
                                            
                                            Picker("Minute", selection: $startMinute) {
                                                ForEach(0..<60) { minute in
                                                    Text(String(format: "%02d", minute))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 20))
                                                        .tag(minute)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 70, height: 120)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: startMinute) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                                        .cornerRadius(12)
                                    }
                                    
                                    // Flèche
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                                        .offset(y: 15)
                                    
                                    // Heure de fin
                                    VStack(alignment: .center, spacing: 12) {
                                        Text("Fin")
                                            .font(.custom("PMackinacProMedium", size: 15))
                                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                        
                                        HStack(spacing: 4) {
                                            Picker("Heure", selection: $endHour) {
                                                ForEach(0..<24) { hour in
                                                    Text(String(format: "%02d", hour))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 20))
                                                        .tag(hour)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 70, height: 120)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: endHour) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                            
                                            Text(":")
                                                .font(.custom("PMackinacProMedium", size: 28))
                                                .foregroundStyle(Color(hex: 0xFCF2D7))
                                                .offset(y: -2)
                                            
                                            Picker("Minute", selection: $endMinute) {
                                                ForEach(0..<60) { minute in
                                                    Text(String(format: "%02d", minute))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 20))
                                                        .tag(minute)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 70, height: 120)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: endMinute) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Résumé de la plage horaire sélectionnée
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                    Text("Bloqué de \(String(format: "%02d:%02d", startHour, startMinute)) à \(String(format: "%02d:%02d", endHour, endMinute))")
                                        .font(.custom("PMackinacProMedium", size: 14))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.green.opacity(0.15))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Séparateur "OU"
                        HStack(spacing: 16) {
                            Rectangle()
                                .fill(Color(hex: 0xFCF2D7, alpha: 0.2))
                                .frame(height: 1)
                            
                            Text("ou choisir un preset")
                                .font(.custom("PMackinacProMedium", size: 14))
                                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(Color(hex: 0xFCF2D7, alpha: 0.2))
                                .frame(height: 1)
                        }
                        .padding(.horizontal)
                        
                        // Presets - EN SECOND, AVEC FEEDBACK VISUEL
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.7))
                                    .font(.system(size: 16))
                                
                                Text("Suggestions rapides")
                                    .font(.custom("PMackinacProMedium", size: 16))
                                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.7))
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                SelectablePresetButton(
                                    preset: .night,
                                    title: "Nuit complète",
                                    subtitle: "22h00 - 7h00",
                                    icon: "moon.stars.fill",
                                    isSelected: selectedPreset == .night
                                ) {
                                    isUpdatingFromPreset = true
                                    selectedPreset = .night
                                    startHour = 22
                                    startMinute = 0
                                    endHour = 7
                                    endMinute = 0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isUpdatingFromPreset = false
                                    }
                                }
                                
                                SelectablePresetButton(
                                    preset: .work,
                                    title: "Heures de travail",
                                    subtitle: "9h00 - 17h00",
                                    icon: "briefcase.fill",
                                    isSelected: selectedPreset == .work
                                ) {
                                    isUpdatingFromPreset = true
                                    selectedPreset = .work
                                    startHour = 9
                                    startMinute = 0
                                    endHour = 17
                                    endMinute = 0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isUpdatingFromPreset = false
                                    }
                                }
                                
                                SelectablePresetButton(
                                    preset: .morning,
                                    title: "Routine matinale",
                                    subtitle: "6h00 - 9h00",
                                    icon: "sunrise.fill",
                                    isSelected: selectedPreset == .morning
                                ) {
                                    isUpdatingFromPreset = true
                                    selectedPreset = .morning
                                    startHour = 6
                                    startMinute = 0
                                    endHour = 9
                                    endMinute = 0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isUpdatingFromPreset = false
                                    }
                                }
                                
                                SelectablePresetButton(
                                    preset: .allDay,
                                    title: "Blocage total",
                                    subtitle: "24h/24",
                                    icon: "lock.shield.fill",
                                    isSelected: selectedPreset == .allDay
                                ) {
                                    isUpdatingFromPreset = true
                                    selectedPreset = .allDay
                                    startHour = 0
                                    startMinute = 0
                                    endHour = 23
                                    endMinute = 59
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isUpdatingFromPreset = false
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
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
        withAnimation {
            strictModeManager.addRule(rule)
        }
        dismiss()
    }
}

struct PresetButton: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .frame(width: 32)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("PMackinacProMedium", size: 16))
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("PMackinacProMedium", size: 13))
                            .foregroundStyle(Color(hex: 0x030302, alpha: 0.7))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: 0x030302, alpha: 0.5))
            }
            .foregroundStyle(Color(hex: 0x030302))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: 0xFCF2D7))
            .cornerRadius(12)
        }
    }
}

// Nouveau composant avec feedback visuel de sélection
struct SelectablePresetButton: View {
    let preset: AddRuleView.PresetType
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icône avec changement de couleur selon sélection
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color(hex: 0x030302) : Color(hex: 0x030302, alpha: 0.7))
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("PMackinacProMedium", size: 16))
                        .foregroundStyle(isSelected ? Color(hex: 0x030302) : Color(hex: 0x030302, alpha: 0.85))
                    
                    Text(subtitle)
                        .font(.custom("PMackinacProMedium", size: 13))
                        .foregroundStyle(isSelected ? Color(hex: 0x030302, alpha: 0.7) : Color(hex: 0x030302, alpha: 0.5))
                }
                
                Spacer()
                
                // Icône de sélection
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(hex: 0x030302, alpha: 0.3))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: 0xFCF2D7) : Color(hex: 0xFCF2D7, alpha: 0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color.green : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    StrictModeView()
}
