import SwiftUI

struct PulsingHeartView: View {
    @ObservedObject var heartRateManager: HeartRateService
    @Binding var pulseArr: [PulseModel]
    let message: String
    
    var body: some View {
        ZStack {
            TimelineView(.animation(minimumInterval: heartRateManager.currentHeartRate > 0 ?
                                  60.0 / Double(heartRateManager.currentHeartRate) : 0.7,
                                  paused: heartRateManager.currentHeartRate == 0)) { timeline in
                ZStack {
                    ForEach(pulseArr) { pulse in
                        PulseAnimation()
                    }
                }
                .onChange(of: timeline.date) { oldValue, newValue in
                    if heartRateManager.currentHeartRate > 0 {
                        let pulseObj = PulseModel()
                        pulseArr.append(pulseObj)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            pulseArr.removeAll(where: { $0.id == pulseObj.id })
                        }
                    }
                }
            }
            
            ZStack {
                Image(systemName: "suit.heart.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundStyle(.pink.gradient)
                    .symbolEffect(.bounce,
                                options: heartRateManager.currentHeartRate > 0 ? .repeating : .default,
                                value: heartRateManager.currentHeartRate)
                
                Text(message)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
            }
        }
    }
}
