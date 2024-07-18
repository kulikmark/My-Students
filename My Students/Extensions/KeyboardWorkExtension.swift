//
//  KeyboardWorkExtension.swift
//  My Students
//
//  Created by Марк Кулик on 02.07.2024.
//

import UIKit

protocol KeyboardHandling: AnyObject {
    var activeTextField: UITextField? { get }
    func registerForKeyboardNotifications()
    func unregisterForKeyboardNotifications()
    func keyboardWillShow(notification: Notification)
    func keyboardWillHide(notification: Notification)
}

// MARK: - Keyboard Handling

extension StudentCardViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Подписываемся на уведомления о появлении и исчезновении клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Отписываемся от уведомлений при исчезновении контроллера
        NotificationCenter.default.removeObserver(self)
    }
    
    // Функция для определения текущего активного текстового поля
    private func activeTextField() -> UITextField? {
        if studentNameTextField.isFirstResponder {
            return studentNameTextField
        } else if parentNameTextField.isFirstResponder {
            return parentNameTextField
        } else if phoneTextField.isFirstResponder {
            return phoneTextField
        } else if lessonPriceTextField.isFirstResponder {
            return lessonPriceTextField
        } else if currencyTextField.isFirstResponder {
            return currencyTextField
        }
        return nil
    }
    
    @objc func keyboardWillShow(notification: Notification) {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            
            // Сдвигаем содержимое scrollView вверх на высоту клавиатуры
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            // Если активное поле не видно, прокручиваем scrollView, чтобы оно было видимым
            if let activeField = activeTextField(), !scrollView.bounds.contains(activeField.frame) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
        
        @objc func keyboardWillHide(notification: Notification) {
            // При скрытии клавиатуры возвращаем содержимое scrollView на исходное положение
            let contentInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
}

extension StudentCardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           switch textField {
           case studentNameTextField:
               if studentTypeSegmentedControl.selectedSegmentIndex == 0 {
                   parentNameTextField.becomeFirstResponder()
               } else {
                   phoneTextField.becomeFirstResponder()
               }
           case parentNameTextField:
               phoneTextField.becomeFirstResponder()
           case phoneTextField:
               lessonPriceTextField.becomeFirstResponder()
           case lessonPriceTextField:
               currencyTextField.becomeFirstResponder()
           case currencyTextField:
               weekdayTextField.becomeFirstResponder()
           case weekdayTextField:
               timeTextField.becomeFirstResponder()
           case timeTextField:
               timeTextField.resignFirstResponder()
           default:
               break
           }
           return true
       }
}
