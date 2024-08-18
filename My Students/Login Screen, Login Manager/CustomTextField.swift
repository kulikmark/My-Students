//
//  CustomTextField.swift
//  My Students
//
//  Created by Марк Кулик on 28.07.2024.
//

import UIKit
import SnapKit

struct CustomTextFieldModel {
    let placeholder: String
    let text: String?
    let isSecureTextEntry: Bool
    let rightView: UIView?
}

class CustomTextField: UIView {
    
    var placeholder: String? {
        get { return textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    var isSecureTextEntry: Bool {
        get { return textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    var rightView: UIView? {
        get { return textField.rightView }
        set {
            textField.rightView = newValue
            textField.rightViewMode = .whileEditing
        }
    }
    
    var clearButtonMode: UITextField.ViewMode {
        get { return textField.clearButtonMode }
        set { textField.clearButtonMode = newValue }
    }
    
    internal let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(textField)
        addSubview(errorLabel)
        
        textField.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(7)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(with model: CustomTextFieldModel) {
        textField.placeholder = model.placeholder
        textField.text = model.text
        textField.isSecureTextEntry = model.isSecureTextEntry
        textField.rightView = model.rightView
    }
    
    func updateTextField(_ text: String?) {
        textField.text = text
    }

    func setError(_ message: String?) -> Bool {
        if let message = message {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.cornerRadius = 8
            textField.layer.masksToBounds = true
            errorLabel.text = message
            errorLabel.isHidden = false
            return true
        } else {
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.cornerRadius = 8
            textField.layer.masksToBounds = true
            errorLabel.isHidden = true
            return false
        }
    }
}
