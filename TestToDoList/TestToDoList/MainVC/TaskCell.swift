//
//  TaskCell.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 15.11.2024.
//

import UIKit
import SnapKit

final class TaskCell: UITableViewCell {
    
    let formatter = DateFormatter()
    var onStatusChange: ((Bool) -> Void)?
    var onEditTaskVC: (() -> Void)?
    var deleteTask: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "ColorViewBlackAndWhite")
        setupLoyout()
        
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    todoLabel
    private lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "ColorTextBlackAndWhite")
        label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    commentToDo label
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "ColorTextBlackAndWhite")
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.numberOfLines = 2
        return label
    }()
    
//    date ToDo label
    private lazy var dateTodoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
//    кнопка изменения статуса задачи выполненно/не выполненно
    private lazy var statusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = UIColor.systemYellow
        button.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func statusButtonTapped() {
        statusButton.isSelected.toggle()
        onStatusChange?(statusButton.isSelected)
        updateToDoLabel(isCompleted: statusButton.isSelected)
    }
    
    func configure(_ todos: Todos) {
        todoLabel.text = todos.todo
        statusButton.isSelected = todos.completed ?? false
        commentLabel.text = todos.commentToDo ?? "Your comment"
        formatter.dateFormat = "dd/MM/yy"
        dateTodoLabel.text = formatter.string(from: todos.date ?? Date())
        updateToDoLabel(isCompleted: statusButton.isSelected)
    }
    
//    метод обновления текса в зависимости от состояния  задачи (выполненно/ не выполненно)
    private func updateToDoLabel(isCompleted: Bool) {
        if isCompleted {
//            задача заверешена
            let attributedString = NSAttributedString(
                string: todoLabel.text ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.gray
                ]
            )
            todoLabel.attributedText = attributedString
        } else {
//            задача не заверешена
            let attrattributedString = NSAttributedString(
                string: todoLabel.text ?? "",
                attributes: [
                    .strikethroughStyle: 0,
                    .foregroundColor: UIColor(named: "ColorTextBlackAndWhite") ?? UIColor.gray
                ]
            )
            todoLabel.attributedText = attrattributedString
        }
    }
}

extension TaskCell {
    private func setupLoyout() {
        prepareView()
        setupConstraint()
    }
    
    private func prepareView() {
        contentView.addSubview(statusButton)
        contentView.addSubview(todoLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(dateTodoLabel)
    }
    
    private func setupConstraint() {
        statusButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).inset(10)
            make.left.equalTo(contentView.snp.left).inset(5)
            make.width.height.equalTo(30)
        }
        todoLabel.snp.makeConstraints { make in
            make.left.equalTo(statusButton.snp.left).inset(45)
            make.right.equalTo(contentView.snp.right).inset(30)
            make.top.equalTo(contentView.snp.top).inset(10)
        }
        commentLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).inset(50)
            make.right.equalTo(contentView.snp.right).inset(30)
            make.top.equalTo(todoLabel.snp.bottom).inset(-7)
        }
        dateTodoLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).inset(50)
            make.top.equalTo(commentLabel.snp.bottom).inset(-7)
            make.bottom.equalTo(contentView.snp.bottom).inset(10)
        }
    }
}

extension TaskCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu in
            let editAction = UIAction(
                title: "Редактировать",
                image: UIImage(systemName: "square.and.pencil")
            ) { _ in
                    print("Редактировать")
                self.onEditTaskVC?()
                }
            let shareAction = UIAction(
                title: "Поделиться",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
                    print("Поделиться")
                }
            let trashAction = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash")
            ) { _ in
                    print("Удалить")
                self.deleteTask?()
                }
            return UIMenu(title: "", children: [editAction, shareAction, trashAction])
        }
    }
}
