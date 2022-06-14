//
//  TodoTests.swift
//  TodoTests
//
//  Created by Deniz Mersinlioğlu on 10.06.2022.
//

import XCTest
import ComposableArchitecture
@testable import Todo

class TodoTests: XCTestCase {
    
    let scheduler = DispatchQueue.test

    func testAddTodo() {
        let id = UUID()
        
        let store = TestStore(
            initialState: TodoListState(),
            reducer: appReducer,
            environment: TodoListEnvironment(
                uuid: { id },
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )
        
        store.send(.addButtonTapped) {
            $0.todos = [Todo(id: id)]
        }
    }
    
    func testCompletingTodos() {
        let firstId = UUID()
        let secondId = UUID()
        
        let store = TestStore(
            initialState: TodoListState(
                todos: [
                    Todo(id: firstId, description: "Milk", completed: false),
                    Todo(id: secondId, description: "Eggs", completed: false),
                ]
            ),
            reducer: appReducer,
            environment: TodoListEnvironment(
                uuid: { fatalError("not implemented") },
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )
        
        store.send(.todo(id: firstId, action: .checkboxToggled)) {
            $0.todos[id: firstId]?.completed = true
        }
        
        scheduler.advance(by: 1)
        
        store.receive(.sortCompletedTodos) {
            $0.todos.swapAt(0, 1)
        }
    }
    
    
    func testDebouncingTodos() {
        let firstId = UUID()
        let secondId = UUID()
        
        let store = TestStore(
            initialState: TodoListState(
                todos: [
                    Todo(id: firstId, description: "Milk", completed: false),
                    Todo(id: secondId, description: "Eggs", completed: false),
                ]
            ),
            reducer: appReducer,
            environment: TodoListEnvironment(
                uuid: { fatalError("not implemented") },
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )
        
        store.send(.todo(id: firstId, action: .checkboxToggled)) {
            $0.todos[id: firstId]?.completed = true
        }
        
        scheduler.advance(by: 0.5)
        
        store.send(.todo(id: firstId, action: .checkboxToggled)) {
            $0.todos[id: firstId]?.completed = false
        }
        
        scheduler.advance(by: 1)
        
        store.receive(.sortCompletedTodos)
    }

}
