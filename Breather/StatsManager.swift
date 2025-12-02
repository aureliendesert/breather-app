import Foundation

@MainActor
class StatsManager: ObservableObject {
    
    static let shared = StatsManager()
    
    @Published var todayAttempts: Int = 0
    @Published var todayBlocked: Int = 0
    
    private let resetHour = 4 // 4 AM local time
    
    init() {
        checkAndResetIfNeeded()
        loadStats()
    }
    
    func recordAttempt(opened: Bool) {
        checkAndResetIfNeeded()
        
        todayAttempts += 1
        if !opened {
            todayBlocked += 1
        }
        
        saveStats()
    }
    
    private func checkAndResetIfNeeded() {
        let lastResetDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date ?? Date.distantPast
        
        if shouldReset(lastReset: lastResetDate) {
            todayAttempts = 0
            todayBlocked = 0
            UserDefaults.standard.set(Date(), forKey: "lastResetDate")
            saveStats()
        }
    }
    
    private func shouldReset(lastReset: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Get today's reset time (4 AM)
        var resetComponents = calendar.dateComponents([.year, .month, .day], from: now)
        resetComponents.hour = resetHour
        resetComponents.minute = 0
        resetComponents.second = 0
        
        guard let todayResetTime = calendar.date(from: resetComponents) else {
            return false
        }
        
        // If it's before 4 AM, the reset time is yesterday at 4 AM
        let actualResetTime: Date
        if now < todayResetTime {
            actualResetTime = calendar.date(byAdding: .day, value: -1, to: todayResetTime)!
        } else {
            actualResetTime = todayResetTime
        }
        
        // Reset if last reset was before the actual reset time
        return lastReset < actualResetTime
    }
    
    private func loadStats() {
        todayAttempts = UserDefaults.standard.integer(forKey: "todayAttempts")
        todayBlocked = UserDefaults.standard.integer(forKey: "todayBlocked")
    }
    
    private func saveStats() {
        UserDefaults.standard.set(todayAttempts, forKey: "todayAttempts")
        UserDefaults.standard.set(todayBlocked, forKey: "todayBlocked")
    }
}
