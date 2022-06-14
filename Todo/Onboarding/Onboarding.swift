//
//  Onboarding.swift
//  Todo
//
//  Created by Deniz Mersinlioğlu on 13.06.2022.
//

import SwiftUI
import ComposableArchitecture

enum OnboardingPage {
    case launch
    case home
}

struct OnboardingState: Equatable {
    var page: OnboardingPage = .launch
    var buttonOffset: CGFloat = 0
    var isAnimating: Bool = false
}

enum OnboardingAction: Equatable {
    case homeButtonTapped
    case homeNavigationDelayCompleted
    case startButtonTapped
    case restartButtonTapped
    case setButtonOffset(CGFloat)
    case toggleAnimation(Bool)
}

struct OnboardingEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let onboardingReducer = Reducer<OnboardingState, OnboardingAction, OnboardingEnvironment> { state, action, environment in
    switch action {
    case .startButtonTapped:
        return .none
        
    case .homeNavigationDelayCompleted:
        state.page = .home;
        return .none
        
    case .homeButtonTapped:
        return Effect(value: .homeNavigationDelayCompleted)
            .delay(for: 0.3, scheduler: environment.mainQueue)
            .eraseToEffect()
        
    case .restartButtonTapped:
        state.page = .launch
        return .none
        
    case let .setButtonOffset(offset):
        state.buttonOffset = offset
        return .none
        
    case let .toggleAnimation(animating):
        state.isAnimating = animating
        return .none
    }
}

struct Onboarding: View {
    
    let store: Store<OnboardingState, OnboardingAction>
    let buttonWidth: CGFloat = UIScreen.main.bounds.width - 80
        
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    NavigationLink(
                        destination: OnboardingHomeView(
                            onRestartTapped: {
                                viewStore.send(.restartButtonTapped)
                            },
                            onStartTapped: {
                                viewStore.send(.startButtonTapped)
                            }
                        ),
                        isActive: viewStore.binding(
                            get: { $0.page == .home },
                            send: { $0 ? .homeButtonTapped : .restartButtonTapped}
                        )
                    ) {
                        EmptyView()
                    }
                    
                    Color("ColorBlue")
                        .ignoresSafeArea(.all, edges: .all)
                    
                    VStack(spacing: 20) {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            Text("Share.")
                                .font(.system(size: 60))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                            
                            Text("""
                        It's not how much we give but
                        how much love we put into giving.
                        """)
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                        }
                        .opacity(viewStore.isAnimating ? 1 : 0)
                        .offset(y: viewStore.isAnimating ? 0 : -40)
                        .animation(.easeOut(duration: 1), value: viewStore.isAnimating)
                        
                        ZStack {
                            CircleGroupView(color: .white, opacity: 0.2)
                                .blur(radius: viewStore.isAnimating ? 0 : 10)
                                .opacity(viewStore.isAnimating ? 1 : 0)
                                .scaleEffect(viewStore.isAnimating ? 1 : 0.5)
                                .animation(.easeOut(duration: 1), value: viewStore.isAnimating)

                            Image("character-1")
                                .resizable()
                                .scaledToFit()
                                .opacity(viewStore.isAnimating ? 1 : 0)
                                .animation(.easeOut(duration: 0.5), value: viewStore.isAnimating)
                        }
                        
                        ZStack {
                            Capsule()
                                .fill(.white.opacity(0.2))
                            
                            Capsule()
                                .fill(.white.opacity(0.2))
                                .padding(8)
                            
                            Text("Get Started")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .offset(x: 20)
                            
                            HStack {
                                Capsule()
                                    .fill(Color("ColorRed"))
                                    .frame(width: viewStore.buttonOffset + 80)
                                
                                Spacer()
                            }
                            
                            HStack {
                                ZStack{
                                    Circle()
                                        .fill(Color("ColorRed"))
                                    
                                    Circle()
                                        .fill(.black.opacity(0.15))
                                        .padding(8)
                                    Image(systemName: "chevron.right.2")
                                        .font(.system(size: 24, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80, alignment: .center)
                                .offset(x: viewStore.buttonOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged{ gesture in
                                            if gesture.translation.width > 0 && viewStore.buttonOffset <= buttonWidth - 80 {
                                                viewStore.send(.setButtonOffset(gesture.translation.width))
                                            }
                                        }
                                        .onEnded { _ in
                                            if viewStore.buttonOffset > buttonWidth / 2 {
                                                viewStore.send(.setButtonOffset(buttonWidth - 80), animation: .default)
                                                viewStore.send(.homeButtonTapped)
                                            } else {
                                                viewStore.send(.setButtonOffset(0), animation: .default)
                                            }
                                        }
                                )
                                .onTapGesture { viewStore.send(.homeButtonTapped) }
                                
                                Spacer()
                            }
                        }
                        .frame(height: 80, alignment: .center)
                        .padding()
                        .opacity(viewStore.isAnimating ? 1 : 0)
                        .offset(y: viewStore.isAnimating ? 0 : 40)
                        .animation(.easeOut(duration: 1), value: viewStore.isAnimating)
                    }
                    .navigationBarHidden(true)
                }
                .onAppear(perform: {
                    viewStore.send(.setButtonOffset(0))
                    viewStore.send(.toggleAnimation(true))
                })
            }
        }
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding(store: Store(
            initialState: OnboardingState(),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        ))
    }
}
