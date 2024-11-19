//
//  ViewController.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 14.11.2024.
//

import UIKit
import SnapKit
import CoreData

class MainViewController: UIViewController {
    
    var taskCell = "taskCell"
    private var todos: [Todos] = []
//    private var todosCoreData: [ToDoList] = []
    
//    MARK: - Core Data
    
    private lazy var fetchResultController: NSFetchedResultsController<ToDoList> = {
        let fetchRequest = ToDoList.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        return fetchResultController
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("Error loading persistent store: \(error.localizedDescription)")
                print("Details: \(error), \(error.userInfo)")
            } else {
                print("DB url - \(description.url?.absoluteString ?? "")")
            }
        }
        return container
    }()
    
//    сохранение данных в CoreData
    private func saveTodosCoreData(_ todos: [Todos]) {
        let context = persistentContainer.viewContext
        
        todos.forEach { todo in
            let toDoEntity = ToDoList(context: context)
            
            toDoEntity.todo = todo.todo
            toDoEntity.date = todo.date
            toDoEntity.completed = todo.completed ?? true
            toDoEntity.commentToDo = todo.commentToDo
        }
        
        do {
            try context.save()
            print("Данные сохраненны в CoreData")
        } catch {
            print("Ошибка сохранения данных в CoreData \(error.localizedDescription)")
        }
    }
    
//    удаление задачи из CoreData
    private func deleteTodosTaskCoreData(_ todos: Todos) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "todo == %@", todos.todo ?? "")
        
        do {
            let result = try context.fetch(fetchRequest)
            if let taskToDelete = result.first {
                context.delete(taskToDelete)
                try context.save()
            } else {
                print("Задача не найденна в Core Data")
            }
        } catch {
            print("Ошибка удаления задачи из CoreData: \(error)")
        }
    }
    
//    загрузка данных из CoreData
    private func fetchTodosFromCoreData() -> [Todos]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        
        do {
            let coreDataTodos = try context.fetch(fetchRequest)
//            конвертируем объекты из CoreDara в модель 'Todos'
            return coreDataTodos.map { coreDataTodo in
                Todos(
                    todo: coreDataTodo.todo,
                    completed: coreDataTodo.completed,
                    commentToDo: coreDataTodo.commentToDo,
                    date: coreDataTodo.date
                )
            }
        } catch {
            print("Ошибка загрузки данных из Core Dara: \(error.localizedDescription)")
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLoyout()
        request()
        
    }
    
//    MARK: - ConetntView
//    заголовок
    private lazy var labelHeadline: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.text = "Задачи"
        label.textAlignment = .left
        return label
    }()

//    поиск
    private lazy var searchBar: UISearchController = {
       let searchBar = UISearchController(searchResultsController: nil)
        searchBar.obscuresBackgroundDuringPresentation = false
        searchBar.searchBar.placeholder = "Search"
        searchBar.searchBar.searchTextField.leftView?.tintColor = .lightGray
        searchBar.searchBar.searchTextField.textColor = .lightGray
        searchBar.searchBar.searchTextField.backgroundColor = UIColor.darkGray
        navigationItem.hidesSearchBarWhenScrolling = false
        return searchBar
    }()
    
//    UIView
    private lazy var buttomView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.darkGray
        return view
    }()
    
//    button newTask
    private lazy var buttonNewTask: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = UIColor.systemYellow
        button.addTarget(self, action: #selector(buttonNewTaskTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonNewTaskTapped() {
        print("buttonNewTask tapped")
    }
    
//    label count task
    private lazy var labelCountTask: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.lightGray
        label.text = "Подсчет кол-ва задач.."
        return label
    }()
    
    private func updateTaskCountLabel() {
        labelCountTask.text = "Кол-во задач: \(todos.count)"
    }
    
//    tableView
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .black
        tableView.separatorColor = .gray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(TaskCell.self, forCellReuseIdentifier: "taskCell")
        return tableView
    }()
    
//    MARK: - Methods
//    Network
    private func request() {
        if let coreDataTodos = fetchTodosFromCoreData(), !coreDataTodos.isEmpty {
            self.todos = coreDataTodos
            self.updateTaskCountLabel()
            self.tableView.reloadData()
        } else {
            NetworkService.shared.requestToDoList { [weak self] todos in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.todos = todos
                    self.saveTodosCoreData(todos)
                    self.updateTaskCountLabel()
                    self.tableView.reloadData()
                }
            }
        }
    }
}

//MARK: - Extension mainVC
extension MainViewController {
    private func setupLoyout() {
        prepereView()
        setupeConstraint()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    private func prepereView() {
        view.addSubview(labelHeadline)
        view.addSubview(buttomView)
        view.addSubview(tableView)
        buttomView.addSubview(buttonNewTask)
        buttomView.addSubview(labelCountTask)
        self.navigationItem.titleView = labelHeadline
        self.navigationItem.searchController = searchBar
    }
    
    private func setupeConstraint() {
        buttomView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).inset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(83)
        }
        buttonNewTask.snp.makeConstraints { make in
            make.right.equalTo(buttomView.snp.right).inset(20)
            make.bottom.equalTo(buttomView.snp.bottom).inset(30)
            make.height.width.equalTo(40)
        }
        labelCountTask.snp.makeConstraints { make in
            make.bottom.equalTo(buttomView.snp.bottom).inset(37)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(140)
            make.left.right.equalTo(view).inset(0)
            make.bottom.equalTo(buttomView.snp.bottom).inset(83)
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskCell, for: indexPath) as? TaskCell
        let todoList = todos[indexPath.row]
        cell?.configure(todoList)
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = todos[indexPath.row]
            todos.remove(at: indexPath.row)
            deleteTodosTaskCoreData(taskToDelete)
            updateTaskCountLabel()

            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
}

