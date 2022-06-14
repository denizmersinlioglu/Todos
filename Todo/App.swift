//
//  TodoApp.swift
//  Todo
//
//  Created by Deniz Mersinlioğlu on 10.06.2022.
//

import SwiftUI
import ComposableArchitecture

@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(
                initialState: .onboarding(.init(page: .launch)),
                reducer: appReducer,
                environment: AppEnvironment(uuid: UUID.init, mainQueue: DispatchQueue.main.eraseToAnyScheduler())
            ))
        }
    }
}
