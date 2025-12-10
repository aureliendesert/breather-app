import Foundation

// Règle de blocage pour une application
struct BlockingRule: Codable, Identifiable {
    let id: UUID
    let appName: String
    let startHour: Int  // 0-23
    let startMinute: Int  // 0-59
    let endHour: Int
    let endMinute: Int
    let isEnabled: Bool
    
    init(id: UUID = UUID(), appName: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, isEnabled: Bool = true) {
        self.id = id
        self.appName = appName
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.isEnabled = isEnabled
    }
    
    // Vérifie si on est dans la plage horaire de blocage
    func isCurrentlyBlocked() -> Bool {
        guard isEnabled else { return false }
        
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        
        guard let currentHour = components.hour,
              let currentMinute = components.minute else {
            return false
        }
        
        let currentMinutes = currentHour * 60 + currentMinute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        // Gestion du passage de minuit
        if endMinutes < startMinutes {
            // Exemple: 22h00 -> 06h00 (passe minuit)
            return currentMinutes >= startMinutes || currentMinutes <= endMinutes
        } else {
            // Exemple: 09h00 -> 17h00 (même jour)
            return currentMinutes >= startMinutes && currentMinutes <= endMinutes
        }
    }
    
    // Description lisible de la plage horaire
    var timeRangeDescription: String {
        let startTime = String(format: "%02d:%02d", startHour, startMinute)
        let endTime = String(format: "%02d:%02d", endHour, endMinute)
        return "\(startTime) - \(endTime)"
    }
}

// Supprime @MainActor pour permettre l'accès synchrone depuis IntentHandler
class StrictModeManager: ObservableObject {
    
    static let shared = StrictModeManager()
    
    @Published var rules: [BlockingRule] = []
    @Published var isStrictModeEnabled: Bool = false
    
    private let rulesKey = "strictModeRules"
    private let enabledKey = "strictModeEnabled"
    
    init() {
        loadRules()
        isStrictModeEnabled = UserDefaults.standard.bool(forKey: enabledKey)
    }
    
    // Vérifie si une app est bloquée en mode strict (accessible de n'importe quel contexte)
    func isAppBlockedInStrictMode(appName: String) -> Bool {
        guard isStrictModeEnabled else { return false }
        
        return rules.contains { rule in
            rule.appName == appName && rule.isCurrentlyBlocked()
        }
    }
    
    // Trouve la règle active pour une app
    func activeRule(for appName: String) -> BlockingRule? {
        guard isStrictModeEnabled else { return nil }
        
        return rules.first { rule in
            rule.appName == appName && rule.isCurrentlyBlocked()
        }
    }
    
    // Ajoute une règle
    @MainActor
    func addRule(_ rule: BlockingRule) {
        rules.append(rule)
        saveRules()
    }
    
    // Supprime une règle
    @MainActor
    func deleteRule(_ rule: BlockingRule) {
        rules.removeAll { $0.id == rule.id }
        saveRules()
    }
    
    // Active/désactive une règle
    @MainActor
    func toggleRule(_ rule: BlockingRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            let updatedRule = BlockingRule(
                id: rule.id,
                appName: rule.appName,
                startHour: rule.startHour,
                startMinute: rule.startMinute,
                endHour: rule.endHour,
                endMinute: rule.endMinute,
                isEnabled: !rule.isEnabled
            )
            rules[index] = updatedRule
            saveRules()
        }
    }
    
    // Active/désactive le mode strict global
    @MainActor
    func toggleStrictMode() {
        isStrictModeEnabled.toggle()
        UserDefaults.standard.set(isStrictModeEnabled, forKey: enabledKey)
    }
    
    // Règles prédéfinies communes
    @MainActor
    func addPresetRule(_ preset: PresetRule) {
        let rule: BlockingRule
        
        switch preset {
        case .workHours(let appName):
            rule = BlockingRule(appName: appName, startHour: 9, startMinute: 0, endHour: 17, endMinute: 0)
        case .nightTime(let appName):
            rule = BlockingRule(appName: appName, startHour: 22, startMinute: 0, endHour: 7, endMinute: 0)
        case .morningRoutine(let appName):
            rule = BlockingRule(appName: appName, startHour: 6, startMinute: 0, endHour: 9, endMinute: 0)
        case .lunchBreak(let appName):
            rule = BlockingRule(appName: appName, startHour: 12, startMinute: 0, endHour: 14, endMinute: 0)
        case .allDay(let appName):
            rule = BlockingRule(appName: appName, startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
        }
        
        addRule(rule)
    }
    
    // MARK: - Persistence
    
    private func saveRules() {
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: rulesKey)
        }
    }
    
    private func loadRules() {
        guard let data = UserDefaults.standard.data(forKey: rulesKey),
              let decoded = try? JSONDecoder().decode([BlockingRule].self, from: data) else {
            return
        }
        rules = decoded
    }
}

// Règles prédéfinies
enum PresetRule {
    case workHours(appName: String)      // 9h-17h
    case nightTime(appName: String)      // 22h-7h
    case morningRoutine(appName: String) // 6h-9h
    case lunchBreak(appName: String)     // 12h-14h
    case allDay(appName: String)         // 24/7
}
