//
//  ContentView.swift
//  Todo
//
//  Created by Deniz Mersinlioğlu on 13.06.2022.
//

import SwiftUI
import ComposableArchitecture
import StoreKit

enum AppState: Equatable {
    case onboarding(OnboardingState)
    case featureList(FeatureListState)
}

enum AppAction: Equatable {
    case onboarding(OnboardingAction)
    case featureList(FeatureListAction)
}

struct AppEnvironment {
    var uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    onboardingReducer.pullback(
        state: /AppState.onboarding,
        action: /AppAction.onboarding,
        environment: { .init(mainQueue: $0.mainQueue) }
    ),
    featureListReducer.pullback(
        state: /AppState.featureList,
        action: /AppAction.featureList,
        environment: { .init(uuid: $0.uuid, mainQueue: $0.mainQueue) }
    ),
    Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        switch action {
        case .onboarding(.startButtonTapped):
            state = .featureList(FeatureListState())
            return .none
            
        case .featureList(.restartButtonTapped):
            state = .onboarding(OnboardingState())
            return .none
        
        case .onboarding:
            return .none
        
        case .featureList:
            return .none
        }
    }
)

struct ContentView: View {
    
    let store: Store<AppState, AppAction>
    
    var body: some View {
        SwitchStore(store) {
            CaseLet(state: /AppState.onboarding, action: AppAction.onboarding) { onboardingStore in
                Onboarding(store: onboardingStore)
            }
            
            CaseLet(state: /AppState.featureList, action: AppAction.featureList) { featureListStore in
                FeatureList(store: featureListStore)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(
            initialState: .onboarding(.init(page: .launch)),
            reducer: appReducer,
            environment: AppEnvironment(uuid: UUID.init, mainQueue: DispatchQueue.main.eraseToAnyScheduler())
        ))
    }
}
