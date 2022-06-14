//
//  TodoList.swift
//  Todo
//
//  Created by Deniz Mersinlioğlu on 10.06.2022.
//

import SwiftUI
import ComposableArchitecture

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}


struct TodoListState: Equatable {
    var editMode: EditMode = .inactive
    var filter: Filter = .all
    var todos: IdentifiedArrayOf<Todo> = []
    
    // Write getters to retrieve data from state.
    var filteredTodos: IdentifiedArrayOf<Todo> {
        switch filter {
        case .active: return todos.filter { !$0.completed }
        case .all: return todos
        case .completed: return todos.filter(\.completed)
        }
    }
}

enum TodoListAction: Equatable {
    case addButtonTapped
    case clearCompletedButtonTapped
    case delete(IndexSet)
    case editModeChanged(EditMode)
    case filterPicked(Filter)
    case move(IndexSet, Int)
    case sortCompletedTodos
    case todo(id: Todo.ID, action: TodoAction)
}

struct TodoListEnvironment {
    var uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let todoListReducer = Reducer<TodoListState, TodoListAction, TodoListEnvironment>.combine(
    todoReducer.forEach(
        state: \.todos,
        action: /TodoListAction.todo(id:action:),
        environment: {_ in TodoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
            
        case .clearCompletedButtonTapped:
            state.todos.removeAll(where: \.completed)
            return .none
            
        case let .delete(indexSet):
            state.todos.remove(atOffsets: indexSet)
            return .none
            
        case let .editModeChanged(editMode):
            state.editMode = editMode
            return .none
            
        case let .filterPicked(filter):
            state.filter = filter
            return .none
            
        case var .move(source, destination):
            if state.filter != .all {
                source = IndexSet(
                    source
                        .map{ state.filteredTodos[$0] }
                        .compactMap { state.todos.index(id: $0.id) }
                )
                destination = state.todos.index(id: state.filteredTodos[destination].id) ?? destination
            }
            state.todos.move(fromOffsets: source, toOffset: destination)
            return Effect(value: .sortCompletedTodos)
                .delay(for: .milliseconds(100), scheduler: environment.mainQueue)
                .eraseToEffect()
            
        case .sortCompletedTodos:
            state.todos.sort { $1.completed && !$0.completed }
            return .none
            
        case .todo(_, action: .checkboxToggled):
            enum TodoCompletionId {}
            return Effect.init(value: .sortCompletedTodos)
                .debounce(
                    id: TodoCompletionId.self,
                    for: 1,
                    scheduler: environment.mainQueue.animation()
                )
            
        case .todo:
            return .none
        }
    }
)

struct TodoList: View {
    
    struct ViewState: Equatable {
        let editMode: EditMode
        let filter: Filter
        let isClearCompletedButtonDisabled: Bool
        
        init(state: TodoListState) {
            self.editMode = state.editMode
            self.filter = state.filter
            self.isClearCompletedButtonDisabled = !state.todos.contains(where: \.completed)
        }
    }
    
    let store: Store<TodoListState, TodoListAction>
    @ObservedObject var viewStore: ViewStore<ViewState, TodoListAction>
    
    init(store: Store<TodoListState, TodoListAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: ViewState.init(state: )))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker(
                "Filter",
                selection: viewStore.binding(get: \.filter, send: TodoListAction.filterPicked)
            ) {
                ForEach(Filter.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                ForEachStore(
                    store.scope(state: \.filteredTodos, action: TodoListAction.todo(id:action:)),
                    content: TodoView.init(store:)
                )
                .onDelete { viewStore.send(.delete($0)) }
                .onMove { viewStore.send(.move($0, $1)) }
            }
        }
        .navigationTitle("Todos")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    Button("Clear Completed") {
                        viewStore.send(.clearCompletedButtonTapped, animation: .default)
                    }
                    .disabled(viewStore.isClearCompletedButtonDisabled)
                    
                    Button("Add Todo") {
                        viewStore.send(.addButtonTapped, animation: .default)
                    }
                    
                    EditButton()
                }
                
            }
        }
        .environment(
            \.editMode,
             viewStore.binding(get: \.editMode, send: TodoListAction.editModeChanged)
        )
    }
}

extension IdentifiedArray where ID == Todo.ID, Element == Todo {
    static let mock: Self = [
        Todo(
            id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEDDEADBEEF")!,
            description: "Check Mail",
            completed: false
        ),
        Todo(
            id: UUID(uuidString: "CAFEBEEF-CAFE-BEEF-CAFE-BEEFCAFEBEEF")!,
            description: "Buy Milk",
            completed: false
        ),
        Todo(
            id: UUID(uuidString: "D00DCAFE-D00D-CAFE-D00D-CAFED00DCAFE")!,
            description: "Call Mom",
            completed: true
        ),
    ]
}

struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
        TodoList(store: .init(
            initialState: TodoListState(todos: .mock),
            reducer: todoListReducer,
            environment: TodoListEnvironment(
                uuid: UUID.init,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        ))
    }
}
