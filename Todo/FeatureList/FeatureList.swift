//
//  FeatureList.swift
//  Todo
//
//  Created by Deniz Mersinlioğlu on 13.06.2022.
//

import SwiftUI
import ComposableArchitecture

enum Feature: String, CaseIterable, Hashable {
    case todo = "Todo"
    case searchWeather = "Search Weather"
}

struct FeatureListState: Equatable {
    var todoList: TodoListState?
    var searchWeather: SearchWeatherState?
}

enum FeatureListAction: Equatable {
    case featureSelected(Feature)
    case backButtonTapped
    case restartButtonTapped
    case todoList(TodoListAction)
    case searchWeather(SearchWeatherAction)
}

struct FeatureListEnvironment {
    var uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let featureListReducer = Reducer<FeatureListState, FeatureListAction, FeatureListEnvironment>.combine(
    todoListReducer
        .optional()
        .pullback(
            state: \.todoList,
            action: /FeatureListAction.todoList,
            environment: { TodoListEnvironment(uuid: $0.uuid, mainQueue: $0.mainQueue) }
        ),
    searchWeatherReducer
        .optional()
        .pullback(
            state: \.searchWeather,
            action: /FeatureListAction.searchWeather,
            environment: { SearchWeatherEnvironment(mainQueue: $0.mainQueue) }
        ),
    Reducer<FeatureListState, FeatureListAction, FeatureListEnvironment> { state, action, environment in
        switch action {
        case .backButtonTapped:
            state.searchWeather = nil
            state.todoList = nil
            return .none
            
        case let .featureSelected(feature):
            switch feature {
            case .todo:
                state.todoList = TodoListState()
                return .none
            case .searchWeather:
                state.searchWeather = SearchWeatherState()
                return .none
            }
            
        case .restartButtonTapped:
            return .none
            
        case .todoList:
            return .none
            
        case .searchWeather:
            return .none
        }
    }
)
    .debug()

struct FeatureList: View {
    
    let store: Store<FeatureListState, FeatureListAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    NavigationLink(
                        destination: IfLetStore(
                            store.scope(state: \.todoList, action: FeatureListAction.todoList),
                            then: TodoList.init(store:)
                        ),
                        isActive: viewStore.binding(
                            get: { $0.todoList != nil },
                            send: { $0 ? .featureSelected(.todo) : .backButtonTapped }
                        )
                    ) {
                        Text(Feature.todo.rawValue)
                    }
                    
                    NavigationLink(
                        destination: IfLetStore(
                            store.scope(state: \.searchWeather, action: FeatureListAction.searchWeather),
                            then: SearchWeather.init(store:)
                        ),
                        isActive: viewStore.binding(
                            get: { $0.searchWeather != nil },
                            send: { $0 ? .featureSelected(.searchWeather) : .backButtonTapped }
                        )
                    ) {
                        Text(Feature.searchWeather.rawValue)
                    }
                }
                .navigationTitle("Features")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Restart") {
                            viewStore.send(.restartButtonTapped)
                        }
                    }
                }
            }
            .navigationViewStyle(.stack)

        }
    }
}

struct FeatureList_Previews: PreviewProvider {
    static var previews: some View {
        FeatureList(
            store: Store(
                initialState: FeatureListState(),
                reducer: featureListReducer,
                environment: FeatureListEnvironment(
                    uuid: UUID.init,
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            )
        )
    }
}
