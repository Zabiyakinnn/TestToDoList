//
//  EditTaskViewController.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 19.11.2024.
//

import UIKit
import SnapKit

final class EditTaskViewController: UIViewController {
    
    private var calendar = UICalendarView()
    private var selectedDate: Date?
    private var dateOfDone = String()
    var todos: Todos?
    var todosCoreData: ToDoList?
    var editTask: (() -> Void)?
    private func showFields() {
        NotificationUtils.showFields(on: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ColorViewBlackAndWhite")
        title = "Редактирование задачи"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "ColorTextBlackAndWhite") ?? UIColor.lightGray
        ]
        setupLoyout()
    }
    
    //    поле ввода названия задачи
    private lazy var textViewNameToDo: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        view.backgroundColor = UIColor.clear
        view.textColor = UIColor(named: "ColorTextBlackAndWhite")
        view.text = todos?.todo
        return view
    }()
    
    //    поле ввода комментария задачи
    private lazy var textViewCommentToDo: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        view.backgroundColor = UIColor.clear
        view.textColor = UIColor(named: "ColorTextBlackAndWhite")
        view.text = todos?.commentToDo ?? "Ваш коментарий"
        return view
    }()
    
//    кнопка выбора даты
    private var  buttonDateToDo: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.setTitle("Date", for: .normal)
        button.contentHorizontalAlignment = .left
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(buttonDateToDoTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonDateToDoTapped() {
        calendar.calendar = .current
        calendar.locale = .current
        calendar.backgroundColor = UIColor(named: "CalendarColor")
        calendar.layer.cornerRadius = 10
        view.addSubview(calendar)

        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendar.selectionBehavior = selection
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(textViewCommentToDo.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).inset(20)
            make.right.equalTo(view.snp.right).inset(20)
            make.bottom.equalTo(view.snp.bottom).inset(70)
        }
    }
    
//    сохранение задачи в Core Data
    @objc func rightButtonItemTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        
        guard let todo = textViewNameToDo.text, !todo.isEmpty,
              let commentToDo = textViewCommentToDo.text, !commentToDo.isEmpty,
              let date = selectedDate else {
            showFields()
            return
        }
        
        if let todoEdit = todosCoreData {
            CoreDataManager.shared.saveEditTask(
                task: todoEdit,
                todo: todo,
                commentToDo: commentToDo,
                date: date,
                completed: todos?.completed ?? false) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success():
                        self.editTask?()
                        self.navigationController?.popViewController(animated: true)
                        print("Измененная задача сохранена в Core Data")
                    case .failure(let error):
                        print("Ошибка сохранения задачи в Core Data: \(error)")
                    }
                }
        } else {
            print("Не удалось найти задачу для редактирования")
        }
    }
    
//    передача даты в кнопку выбора даты
    private func formatterDate(_ date: Date?) -> String {
        guard let date = date else { return "Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    private func updateButtonDateTitle(with date: Date?) {
        let formattedDate = formatterDate(date)
        buttonDateToDo.setTitle(formattedDate, for: .normal)
        dateOfDone = formattedDate
    }
    
    //    скрытие клавиатуры
    private func dismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        textViewNameToDo.endEditing(true)
        textViewCommentToDo.endEditing(true)
    }
}

extension EditTaskViewController {
    private func setupLoyout() {
        prepereView()
        setupConstraint()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .plain,
            target: self,
            action: #selector(rightButtonItemTapped))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.systemYellow
        navigationController?.navigationBar.tintColor = UIColor.systemYellow
        dismissKeyboard()
        updateButtonDateTitle(with: todos?.date)
    }
    
    private func prepereView() {
        view.addSubview(textViewNameToDo)
        view.addSubview(buttonDateToDo)
        view.addSubview(textViewCommentToDo)
    }
    
    private func setupConstraint() {
        textViewNameToDo.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(105)
            make.left.equalTo(view.snp.left).inset(20)
            make.right.equalTo(view.snp.right).inset(20)
            make.height.equalTo(80)
        }
        buttonDateToDo.snp.makeConstraints { make in
            make.top.equalTo(textViewNameToDo.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left).inset(24)
            make.width.equalTo(100)
            make.height.equalTo(35)
        }
        textViewCommentToDo.snp.makeConstraints { make in
            make.top.equalTo(buttonDateToDo.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).inset(20)
            make.right.equalTo(view.snp.right).inset(20)
            make.height.equalTo(140)
        }
    }
}

//MARK: - UICalendarSelectionSingleDateDelegate
extension EditTaskViewController: UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents, let date = dateComponents.date else { return }
        
        selectedDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        let selectedDate = dateFormatter.string(from: date)
        dateOfDone = selectedDate
        
        buttonDateToDo.setTitle(selectedDate, for: .normal)
        calendar.removeFromSuperview()
    }
    
}



//if textViewNameToDo.hasText && textViewCommentToDo.hasText && dateOfDone != "dd/MM/yy" {
//    
//    let formatter = DateFormatter()
//    formatter.dateFormat = "dd/MM/yy"
//    
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    let context = appDelegate.persistentContainer.viewContext
//    
////            проверяем существует ли уже todos
//    if let todosEdit = todosCoreData {
////                print("Редактируем задачу \(todosEdit)")
//        todosEdit.todo = textViewNameToDo.text
//        todosEdit.commentToDo = textViewCommentToDo.text
//        todosEdit.date = formatter.date(from: dateOfDone)
//        todosEdit.completed = todosCoreData?.completed != nil
//        do {
//            try context.save()
//            self.editTask?()
////                    print("Задача сохранена в Core Data \(todosEdit)")
//            navigationController?.popViewController(animated: true)
//        } catch {
//            print("Error \(error.localizedDescription)")
//        }
//    } else {
//        print("Не удалось найти задачу для редактирования")
//    }
//} else {
//    showFields()
//}
