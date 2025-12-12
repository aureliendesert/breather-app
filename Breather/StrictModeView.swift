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
                .padding(.top, 24)
                .padding(.bottom, 20)
                .background(Color(hex: 0x030302))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Toggle du mode strict global avec meilleur design
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "shield.lefthalf.filled")
                                            .font(.system(size: 18))
                                            .foregroundStyle(strictModeManager.isStrictModeEnabled ? Color.green : Color(hex: 0xFCF2D7, alpha: 0.5))
                                        
                                        Text("Mode strict")
                                            .font(.custom("PMackinacProMedium", size: 18))
                                            .foregroundStyle(Color(hex: 0xFCF2D7))
                                    }
                                    
                                    Text("Bloquez les apps pendant certaines heures de la journée")
                                        .font(.custom("PMackinacProMedium", size: 13))
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
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: 0xFCF2D7, alpha: 0.06))
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
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
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddRule) {
            AddRuleView()
        }
    }
    
    private var disabledStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "moon.zzz")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.3))
            
            Text("Mode strict désactivé")
                .font(.custom("PMackinacProMedium", size: 20))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
            
            Text("Activez le mode strict ci-dessus pour commencer à créer des règles de blocage")
                .font(.custom("PMackinacProMedium", size: 14))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.4))
            
            Text("Aucune règle")
                .font(.custom("PMackinacProMedium", size: 22))
                .foregroundStyle(Color(hex: 0xFCF2D7))
            
            Text("Créez votre première règle de blocage pour commencer")
                .font(.custom("PMackinacProMedium", size: 14))
                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: { showingAddRule = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Créer une règle")
                        .font(.custom("PMackinacProMedium", size: 15))
                }
                .foregroundStyle(Color(hex: 0x030302))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(hex: 0xFCF2D7))
                .cornerRadius(10)
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var rulesListView: some View {
        VStack(spacing: 0) {
            // Header de la section avec compteur
            HStack {
                Text("Mes règles")
                    .font(.custom("PMackinacProMedium", size: 16))
                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                
                Text("(\(strictModeManager.rules.count))")
                    .font(.custom("PMackinacProMedium", size: 14))
                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                
                Spacer()
                
                // Indicateur de règles actives
                let activeCount = strictModeManager.rules.filter { $0.isCurrentlyBlocked() }.count
                if activeCount > 0 {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Text("\(activeCount) active\(activeCount > 1 ? "s" : "")")
                            .font(.custom("PMackinacProMedium", size: 12))
                            .foregroundStyle(Color.red)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            
            // Liste des règles
            VStack(spacing: 10) {
                ForEach(strictModeManager.rules) { rule in
                    RuleRowView(rule: rule)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct RuleRowView: View {
    let rule: BlockingRule
    @StateObject var strictModeManager = StrictModeManager.shared
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Info de l'app et horaire
            VStack(alignment: .leading, spacing: 6) {
                Text(rule.appName)
                    .font(.custom("PMackinacProMedium", size: 17))
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.6))
                    
                    Text(rule.timeRangeDescription)
                        .font(.custom("PMackinacProMedium", size: 14))
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                }
                
                HStack(spacing: 6) {
                    if rule.isCurrentlyBlocked() {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                        Text("Actif maintenant")
                            .font(.custom("PMackinacProMedium", size: 12))
                            .foregroundStyle(Color.red)
                    } else {
                        Circle()
                            .fill(Color(hex: 0xFCF2D7, alpha: 0.3))
                            .frame(width: 6, height: 6)
                        Text("En attente")
                            .font(.custom("PMackinacProMedium", size: 12))
                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                    }
                }
            }
            
            Spacer()
            
            // Boutons d'action
            HStack(spacing: 8) {
                // Bouton éditer
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: 0xFCF2D7, alpha: 0.1))
                        .cornerRadius(8)
                }
                
                // Bouton supprimer
                Button(action: {
                    withAnimation {
                        strictModeManager.deleteRule(rule)
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.red.opacity(0.8))
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: 0xFCF2D7, alpha: 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            rule.isCurrentlyBlocked() ? Color.red.opacity(0.5) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .sheet(isPresented: $showingEditSheet) {
            EditRuleView(rule: rule)
        }
    }
}

struct EditRuleView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var strictModeManager = StrictModeManager.shared
    let rule: BlockingRule
    
    @State private var selectedApp: String
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    @State private var selectedPreset: AddRuleView.PresetType? = nil
    @State private var isUpdatingFromPreset = false
    
    let availableApps = ["Instagram", "TikTok", "X (Twitter)", "Facebook", "YouTube", "Reddit", "LinkedIn", "Snapchat", "WhatsApp", "Messenger"]
    
    init(rule: BlockingRule) {
        self.rule = rule
        _selectedApp = State(initialValue: rule.appName)
        _startHour = State(initialValue: rule.startHour)
        _startMinute = State(initialValue: rule.startMinute)
        _endHour = State(initialValue: rule.endHour)
        _endMinute = State(initialValue: rule.endMinute)
    }
    
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
                    .frame(width: 80, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Modifier la règle")
                        .font(.custom("PMackinacProMedium", size: 18))
                        .foregroundStyle(Color(hex: 0xFCF2D7))
                    
                    Spacer()
                    
                    Button("Sauver") {
                        saveRule()
                    }
                    .font(.custom("PMackinacProMedium", size: 15))
                    .bold()
                    .foregroundStyle(Color(hex: 0x030302))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(hex: 0xFCF2D7))
                    .cornerRadius(8)
                    .frame(width: 80, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .background(Color(hex: 0x030302))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Sélection de l'app
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "app.badge")
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                                    .font(.system(size: 16))
                                
                                Text("Application à bloquer")
                                    .font(.custom("PMackinacProMedium", size: 16))
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                            }
                            
                            Picker("Application", selection: $selectedApp) {
                                ForEach(availableApps, id: \.self) { app in
                                    Text(app)
                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                        .font(.custom("PMackinacProMedium", size: 16))
                                        .tag(app)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                            .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                            .cornerRadius(12)
                            .colorScheme(.dark)
                        }
                        
                        Divider()
                            .background(Color(hex: 0xFCF2D7, alpha: 0.2))
                        
                        // Personnalisation horaires
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock.arrow.2.circlepath")
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                                    .font(.system(size: 16))
                                
                                Text("Définir les horaires")
                                    .font(.custom("PMackinacProMedium", size: 16))
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                            }
                            
                            // Sélecteurs d'horaires
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    // Heure de début
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Début")
                                            .font(.custom("PMackinacProMedium", size: 14))
                                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                        
                                        HStack(spacing: 4) {
                                            Picker("Heure", selection: $startHour) {
                                                ForEach(0..<24) { hour in
                                                    Text(String(format: "%02d", hour))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(hour)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: startHour) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                            
                                            Text(":")
                                                .font(.custom("PMackinacProMedium", size: 24))
                                                .foregroundStyle(Color(hex: 0xFCF2D7))
                                                .offset(y: -2)
                                            
                                            Picker("Minute", selection: $startMinute) {
                                                ForEach(0..<60) { minute in
                                                    Text(String(format: "%02d", minute))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(minute)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: startMinute) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                        }
                                        .padding(12)
                                        .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                                        .cornerRadius(10)
                                    }
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                                        .offset(y: 12)
                                    
                                    // Heure de fin
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Fin")
                                            .font(.custom("PMackinacProMedium", size: 14))
                                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                        
                                        HStack(spacing: 4) {
                                            Picker("Heure", selection: $endHour) {
                                                ForEach(0..<24) { hour in
                                                    Text(String(format: "%02d", hour))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(hour)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: endHour) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                            
                                            Text(":")
                                                .font(.custom("PMackinacProMedium", size: 24))
                                                .foregroundStyle(Color(hex: 0xFCF2D7))
                                                .offset(y: -2)
                                            
                                            Picker("Minute", selection: $endMinute) {
                                                ForEach(0..<60) { minute in
                                                    Text(String(format: "%02d", minute))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(minute)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: endMinute) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                        }
                                        .padding(12)
                                        .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                                        .cornerRadius(10)
                                    }
                                }
                                
                                // Résumé
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                    Text("Bloqué de \(String(format: "%02d:%02d", startHour, startMinute)) à \(String(format: "%02d:%02d", endHour, endMinute))")
                                        .font(.custom("PMackinacProMedium", size: 13))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.green.opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Séparateur
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color(hex: 0xFCF2D7, alpha: 0.2))
                                .frame(height: 1)
                            
                            Text("ou choisir un preset")
                                .font(.custom("PMackinacProMedium", size: 13))
                                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(Color(hex: 0xFCF2D7, alpha: 0.2))
                                .frame(height: 1)
                        }
                        
                        // Presets
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.7))
                                    .font(.system(size: 15))
                                
                                Text("Suggestions rapides")
                                    .font(.custom("PMackinacProMedium", size: 15))
                                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.7))
                            }
                            
                            VStack(spacing: 10) {
                                SelectablePresetButton(
                                    preset: .night,
                                    title: "Nuit complète",
                                    subtitle: "22h00 - 7h00",
                                    icon: "moon.stars.fill",
                                    isSelected: selectedPreset == .night
                                ) {
                                    applyPreset(.night, start: (22, 0), end: (7, 0))
                                }
                                
                                SelectablePresetButton(
                                    preset: .work,
                                    title: "Heures de travail",
                                    subtitle: "9h00 - 17h00",
                                    icon: "briefcase.fill",
                                    isSelected: selectedPreset == .work
                                ) {
                                    applyPreset(.work, start: (9, 0), end: (17, 0))
                                }
                                
                                SelectablePresetButton(
                                    preset: .morning,
                                    title: "Routine matinale",
                                    subtitle: "6h00 - 9h00",
                                    icon: "sunrise.fill",
                                    isSelected: selectedPreset == .morning
                                ) {
                                    applyPreset(.morning, start: (6, 0), end: (9, 0))
                                }
                                
                                SelectablePresetButton(
                                    preset: .allDay,
                                    title: "Blocage total",
                                    subtitle: "24h/24",
                                    icon: "lock.shield.fill",
                                    isSelected: selectedPreset == .allDay
                                ) {
                                    applyPreset(.allDay, start: (0, 0), end: (23, 59))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    private func applyPreset(_ preset: AddRuleView.PresetType, start: (Int, Int), end: (Int, Int)) {
        isUpdatingFromPreset = true
        selectedPreset = preset
        startHour = start.0
        startMinute = start.1
        endHour = end.0
        endMinute = end.1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isUpdatingFromPreset = false
        }
    }
    
    private func saveRule() {
        strictModeManager.updateRule(
            rule,
            appName: selectedApp,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute
        )
        dismiss()
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
                // Header
                HStack {
                    Button("Annuler") {
                        dismiss()
                    }
                    .font(.custom("PMackinacProMedium", size: 16))
                    .foregroundStyle(Color(hex: 0xFCF2D7))
                    .frame(width: 80, alignment: .leading)
                    
                    Spacer()
                    
                    Text("Nouvelle règle")
                        .font(.custom("PMackinacProMedium", size: 18))
                        .foregroundStyle(Color(hex: 0xFCF2D7))
                    
                    Spacer()
                    
                    Button("Créer") {
                        addRule()
                    }
                    .font(.custom("PMackinacProMedium", size: 15))
                    .bold()
                    .foregroundStyle(Color(hex: 0x030302))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(hex: 0xFCF2D7))
                    .cornerRadius(8)
                    .frame(width: 80, alignment: .trailing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .background(Color(hex: 0x030302))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Sélection de l'app
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "app.badge")
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                                    .font(.system(size: 16))
                                
                                Text("Application à bloquer")
                                    .font(.custom("PMackinacProMedium", size: 16))
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                            }
                            
                            Picker("Application", selection: $selectedApp) {
                                ForEach(availableApps, id: \.self) { app in
                                    Text(app)
                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                        .font(.custom("PMackinacProMedium", size: 16))
                                        .tag(app)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                            .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                            .cornerRadius(12)
                            .colorScheme(.dark)
                        }
                        
                        Divider()
                            .background(Color(hex: 0xFCF2D7, alpha: 0.2))
                        
                        // NOUVEAU : Personnalisation en PREMIER
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock.arrow.2.circlepath")
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                                    .font(.system(size: 16))
                                
                                Text("Définir les horaires")
                                    .font(.custom("PMackinacProMedium", size: 16))
                                    .foregroundStyle(Color(hex: 0xFCF2D7))
                            }
                            
                            // Sélecteurs d'horaires - TOUJOURS VISIBLES
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    // Heure de début
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Début")
                                            .font(.custom("PMackinacProMedium", size: 14))
                                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                        
                                        HStack(spacing: 4) {
                                            Picker("Heure", selection: $startHour) {
                                                ForEach(0..<24) { hour in
                                                    Text(String(format: "%02d", hour))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(hour)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: startHour) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                            
                                            Text(":")
                                                .font(.custom("PMackinacProMedium", size: 24))
                                                .foregroundStyle(Color(hex: 0xFCF2D7))
                                                .offset(y: -2)
                                            
                                            Picker("Minute", selection: $startMinute) {
                                                ForEach(0..<60) { minute in
                                                    Text(String(format: "%02d", minute))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(minute)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: startMinute) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                        }
                                        .padding(12)
                                        .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                                        .cornerRadius(10)
                                    }
                                    
                                    // Flèche
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                                        .offset(y: 12)
                                    
                                    // Heure de fin
                                    VStack(alignment: .center, spacing: 10) {
                                        Text("Fin")
                                            .font(.custom("PMackinacProMedium", size: 14))
                                            .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                        
                                        HStack(spacing: 4) {
                                            Picker("Heure", selection: $endHour) {
                                                ForEach(0..<24) { hour in
                                                    Text(String(format: "%02d", hour))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(hour)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: endHour) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                            
                                            Text(":")
                                                .font(.custom("PMackinacProMedium", size: 24))
                                                .foregroundStyle(Color(hex: 0xFCF2D7))
                                                .offset(y: -2)
                                            
                                            Picker("Minute", selection: $endMinute) {
                                                ForEach(0..<60) { minute in
                                                    Text(String(format: "%02d", minute))
                                                        .foregroundColor(Color(hex: 0xFCF2D7))
                                                        .font(.custom("PMackinacProMedium", size: 18))
                                                        .tag(minute)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 60, height: 110)
                                            .compositingGroup()
                                            .colorScheme(.dark)
                                            .onChange(of: endMinute) { _ in
                                                if !isUpdatingFromPreset {
                                                    selectedPreset = nil
                                                }
                                            }
                                        }
                                        .padding(12)
                                        .background(Color(hex: 0xFCF2D7, alpha: 0.05))
                                        .cornerRadius(10)
                                    }
                                }
                                
                                // Résumé de la plage horaire sélectionnée
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                    Text("Bloqué de \(String(format: "%02d:%02d", startHour, startMinute)) à \(String(format: "%02d:%02d", endHour, endMinute))")
                                        .font(.custom("PMackinacProMedium", size: 13))
                                        .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.8))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.green.opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Séparateur "OU"
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color(hex: 0xFCF2D7, alpha: 0.2))
                                .frame(height: 1)
                            
                            Text("ou choisir un preset")
                                .font(.custom("PMackinacProMedium", size: 13))
                                .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.5))
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(Color(hex: 0xFCF2D7, alpha: 0.2))
                                .frame(height: 1)
                        }
                        
                        // Presets - EN SECOND, AVEC FEEDBACK VISUEL
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.7))
                                    .font(.system(size: 15))
                                
                                Text("Suggestions rapides")
                                    .font(.custom("PMackinacProMedium", size: 15))
                                    .foregroundStyle(Color(hex: 0xFCF2D7, alpha: 0.7))
                            }
                            
                            VStack(spacing: 10) {
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
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
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
            HStack(spacing: 10) {
                // Icône avec changement de couleur selon sélection
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Color(hex: 0x030302) : Color(hex: 0x030302, alpha: 0.7))
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.custom("PMackinacProMedium", size: 15))
                        .foregroundStyle(isSelected ? Color(hex: 0x030302) : Color(hex: 0x030302, alpha: 0.85))
                    
                    Text(subtitle)
                        .font(.custom("PMackinacProMedium", size: 12))
                        .foregroundStyle(isSelected ? Color(hex: 0x030302, alpha: 0.7) : Color(hex: 0x030302, alpha: 0.5))
                }
                
                Spacer()
                
                // Icône de sélection
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: 0x030302, alpha: 0.3))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color(hex: 0xFCF2D7) : Color(hex: 0xFCF2D7, alpha: 0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected ? Color.green : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    StrictModeView()
}
