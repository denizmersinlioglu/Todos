//
//  TodoView.swift
//  Todo
//
//  Created by Deniz Mersinlioğlu on 10.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Identifiable, Equatable {
    var id: UUID
    var description: String
    var completed: Bool
    
    init(
        id: UUID = UUID(),
        description: String = "",
        completed: Bool = false
    ) {
        self.id = id
        self.description = description
        self.completed = completed
    }
}

enum TodoAction: Equatable {
    case checkboxToggled
    case textFieldChanged(String)
}

struct TodoEnvironment {}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment>{ state, action, environment in
    switch action {
    case .checkboxToggled:
        state.completed.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxToggled) }) {
                    Image(systemName: viewStore.completed ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField(
                    "Untitled todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: TodoAction.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.completed ? .gray : .primary)
        }
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView(
            store: .init(
                initialState: Todo(description: "Hello world", completed: false),
                reducer: todoReducer,
                environment: TodoEnvironment()
            )
        )
    }
}
