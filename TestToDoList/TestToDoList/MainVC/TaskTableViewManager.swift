//
//  TaskTableViewManager.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 21.11.2024.
//

import UIKit

final class TaskTableViewManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private var todos: [Todos]
    private var filteredTodo: [Todos] = []
    private var isFiltering: Bool = false
    
    private let taskCell: String
    
//    замыкания для событий
    var onUpdateTaskStatus: ((Todos, Bool) -> Void)?
    var onDeleteTask: ((Todos) -> Void)?
    var onSelectTask: ((Todos) -> Void)?
    var onEditTask: ((Todos) -> Void)?
    
    init(todos: [Todos], taskCell: String) {
        self.todos = todos
        self.taskCell = taskCell
        super.init()
    }
    
    func updateTodos(_ todos: [Todos]) {
        self.todos = todos
    }
    
    func updateSearchResult(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
//            если текст пустой
            filteredTodo = todos
            isFiltering = false
            return
        }
        //        фильтрация массива
        filteredTodo = todos.filter { todo in
            (todo.todo?.lowercased().contains(searchText.lowercased()) ?? false) ||
            (todo.commentToDo?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        isFiltering = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredTodo.count : todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as? TaskCell
        let task = isFiltering ? filteredTodo[indexPath.row] : todos[indexPath.row]
        cell?.configure(task)
        
//        обновление статуса задачи
        cell?.onStatusChange = { [weak self] newStatus in
            guard let self = self else { return }
            self.onUpdateTaskStatus?(task, newStatus)
        }
        
        cell?.onEditTaskVC = { [weak self] in
            guard let self = self else { return }
            self.onEditTask?(task)
        }
        
        cell?.deleteTask = { [weak self] in
            guard let self = self else { return }
            self.onDeleteTask?(task)
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = isFiltering ? filteredTodo[indexPath.row] : todos[indexPath.row]
        onSelectTask?(selectedTask)
    }
    
    //    delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = isFiltering ? filteredTodo[indexPath.row] : todos[indexPath.row]
            onDeleteTask?(taskToDelete)
        }
    }
}
