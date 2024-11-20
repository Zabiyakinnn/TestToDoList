//
//  NotificationUtils.swift
//  TestToDoList
//
//  Created by Дмитрий Забиякин on 20.11.2024.
//

import UIKit
import SnapKit

public final class NotificationUtils {
    
    static func showFields(on viewController: UIViewController) {
        
        let notificationView = UIView()
        notificationView.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        notificationView.layer.cornerRadius = 10
        
        let label = UILabel()
        label.text = "Ошибка сохранения. Заполните все поля"
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        
        viewController.view.addSubview(notificationView)
        notificationView.addSubview(label)
        
        notificationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        
        notificationView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            notificationView.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.5, animations: {
                notificationView.alpha = 0
            }) { _ in
                notificationView.removeFromSuperview()
            }
        }
    }
}
