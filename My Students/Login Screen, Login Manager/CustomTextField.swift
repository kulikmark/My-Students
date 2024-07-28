//
//  CustomTextField.swift
//  My Students
//
//  Created by Марк Кулик on 28.07.2024.
//

import UIKit
import SnapKit

class CustomTextField: UIView {
    let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        return textField
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = true
        return label
    }()
    
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
        get {
            return textField.rightView
        }
        set {
            textField.rightView = newValue
            textField.rightViewMode = .whileEditing
        }
    }
    
    var clearButtonMode: UITextField.ViewMode {
        get { return textField.clearButtonMode }
        set { textField.clearButtonMode = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(textField)
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
    
    // Add border color and width change for error state
    // Add border color and width change for error state
        func setError(_ message: String?) -> Bool {
            if let message = message {
                textField.layer.borderWidth = 1
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.cornerRadius = 8 // Set the corner radius manually
                textField.layer.masksToBounds = true
                errorLabel.text = message
                errorLabel.isHidden = false
                return true
            } else {
                textField.layer.borderWidth = 0
                textField.layer.borderColor = UIColor.clear.cgColor
                textField.layer.cornerRadius = 8 // Reset the corner radius
                textField.layer.masksToBounds = true
                errorLabel.isHidden = true
                return false
            }
        }
    }

