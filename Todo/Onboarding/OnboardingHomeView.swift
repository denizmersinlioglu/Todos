//
//  OnboardingHomeView.swift
//  Todo
//
//  Created by Deniz Mersinlioğlu on 13.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingHomeView: View {
    
    let onRestartTapped: () -> Void
    let onStartTapped: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            ZStack {
                CircleGroupView(color: .gray, opacity: 0.1)
                
                Image("character-2")
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            
            Text("The time that leads to mastery is dependent on the intensity of your focus")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Button(action: onRestartTapped) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .imageScale(.large)
                Text("Restart")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            
            Button(action: onStartTapped) {
                Image(systemName: "arrow.up.forward.app")
                    .imageScale(.large)
                Text("Start")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(Color("ColorRed"))
            .controlSize(.large)
        }
        .navigationBarHidden(true)
    }
}


struct OnboardingHomeView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingHomeView(
            onRestartTapped: {},
            onStartTapped: {}
        )
    }
}
