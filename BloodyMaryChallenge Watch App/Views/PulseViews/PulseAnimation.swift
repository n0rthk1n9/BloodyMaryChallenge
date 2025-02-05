//
//  PulseAnimation.swift
//  BloodyMaryChallenge Watch App
//
//  Created by Jan Armbrust on 05.02.2025.
//

import SwiftUI

struct PulseAnimation: View {
    @State var enablePulse = false

    var body: some View {
        Image(systemName: "suit.heart.fill")
            .resizable()
            .frame(width: 150, height: 150)
            .foregroundStyle(.pink)
            .opacity(enablePulse ? 0 : 0.3)
            .scaleEffect(enablePulse ? 3 : 1)
            .blur(radius: enablePulse ? 2 : 0)
            .onAppear {
                // Play haptic feedback when pulse starts
                WKInterfaceDevice.current().play(.click)

                withAnimation(.linear(duration: 3)) {
                    enablePulse = true
                }
            }
    }
}
