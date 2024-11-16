//
//  ToDoList+CoreDataProperties.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 16.11.2024.
//
//

import Foundation
import CoreData

@objc(ToDoList)
public class ToDoList: NSManagedObject {}

extension ToDoList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoList> {
        return NSFetchRequest<ToDoList>(entityName: "ToDoList")
    }

    @NSManaged public var todo: String?
    @NSManaged public var completed: Bool
    @NSManaged public var commentToDo: String?
    @NSManaged public var date: Date?

}

extension ToDoList : Identifiable {}
