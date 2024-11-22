//
//  NewTaskViewController.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 19.11.2024.
//

import UIKit
import SnapKit

final class NewTaskViewController: UIViewController {
    
    private var calendar = UICalendarView()
    private var selectedDate: Date?
    private var dateOfDone = String()
    private var todos: ToDoList?
    var newToDo: (() -> Void)?
    private func showFields() {
        NotificationUtils.showFields(on: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ColorViewBlackAndWhite")
        title = "Новая задача"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "ColorTextBlackAndWhite") ?? UIColor.lightGray
        ]
        setupLoyout()
    }
    
    //    текст укажите название
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "ColorTextBlackAndWhite")
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.text = "Укажите название"
        label.textAlignment = .center
        return label
    }()
    
    //    поле ввода названия задачи
    private lazy var textViewNameToDo: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = UIColor.black
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    //    текст напишите комментарий
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "ColorTextBlackAndWhite")
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.text = "Напишите комментарий"
        label.textAlignment = .center
        return label
    }()
    
    //    поле ввода комментария задачи
    private lazy var textViewCommentToDo: UITextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.font = UIFont.systemFont(ofSize: 16)
        view.backgroundColor = UIColor.lightGray
        view.textColor = UIColor.black
        return view
    }()
    
    //    текст укажите дату
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "ColorTextBlackAndWhite")
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.text = "Укажите дату"
        label.textAlignment = .center
        return label
    }()
    
//    кнопка выбора даты
    private var  buttonDateToDo: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .darkGray
        let calendarImage = UIImage(systemName: "calendar")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        button.setImage(calendarImage, for: .normal)
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
            make.top.equalTo(buttonDateToDo.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).inset(20)
            make.right.equalTo(view.snp.right).inset(20)
            make.bottom.equalTo(view.snp.bottom).inset(90)
        }
    }
    
//    сохранение задачи в Core Data
    @objc func rightButtonItemTapped() {
        guard let todo = textViewNameToDo.text, !todo.isEmpty,
              let commentToDo = textViewNameToDo.text, !commentToDo.isEmpty,
              let date = selectedDate else {
            showFields()
            return
        }
        CoreDataManager.shared.saveNewTask(
            todo: todo,
            commentToDo: commentToDo,
            date: date) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success():
                    self.newToDo?()
                    self.navigationController?.popViewController(animated: true)
                    print("Новая задача сохраненна в Core Data")
                case .failure(let error):
                    print("Ошибка сохранения данных в Core Data: \(error.localizedDescription)")
                }
            }
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

extension NewTaskViewController {
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
    }
    
    private func prepereView() {
        view.addSubview(titleLabel)
        view.addSubview(textViewNameToDo)
        view.addSubview(commentLabel)
        view.addSubview(textViewCommentToDo)
        view.addSubview(dateLabel)
        view.addSubview(buttonDateToDo)
    }
    
    private func setupConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(120)
            make.left.equalTo(view.snp.left).inset(20)
        }
        textViewNameToDo.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).inset(20)
            make.right.equalTo(view.snp.right).inset(20)
            make.height.equalTo(70)
        }
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(textViewNameToDo.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).inset(20)
        }
        textViewCommentToDo.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).inset(20)
            make.right.equalTo(view.snp.right).inset(20)
            make.height.equalTo(70)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(textViewCommentToDo.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).inset(20)
        }
        buttonDateToDo.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left).inset(20)
            make.width.equalTo(100)
            make.height.equalTo(35)
        }
    }
}

//MARK: - UICalendarSelectionSingleDateDelegate
extension NewTaskViewController: UICalendarSelectionSingleDateDelegate {
    
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
