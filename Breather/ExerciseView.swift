import SwiftUI

struct ExerciseView: View {
    
    @EnvironmentObject var state: ExerciseState
    
    var body: some View {
        VStack(spacing: 40) {
            
            Spacer()
            
            Text("Take a breath")
                .font(.largeTitle)
            
            Text("You were about to open \(state.appName)")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("Open \(state.appName)") {
                    state.complete(openApp: true)
                }
                .buttonStyle(.bordered)
                
                Button("I'm good") {
                    state.complete(openApp: false)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview {
    ExerciseView()
        .environmentObject(ExerciseState.shared)
}
