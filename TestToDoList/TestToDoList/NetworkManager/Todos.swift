//
//  Todos.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 15.11.2024.
//

import Foundation

struct Todo: Codable {
    var todos: [Todos]?
}

struct Todos: Codable {
    var id: Int?
    var todo: String?
    var completed: Bool?
    var userId: Int?
    var commentToDo: String?
    var date: Date?
}
