//
//  RegistrationViews.swift
//  rfpr
//
//  Created by poliorang on 01.08.2023.
//

import UIKit

class RegistrationViews {
    private let view: UIView!
    
    init(view: UIView, updateUser: User?) {
        self.view = view
        
        setupMainView()
        constraintLoginTextField(loginTextField)
        constraintPasswordTextField(passwordTextField)
        constraintRoleTextField(roleTextField)
        constraintRegistrationButton(registrationButton)
        setupUpdatedUser(updateUser)
        connectTextFieldWithPicker()
    }
    
    let loginTextField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        textField.placeholder = "Логин"
        
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        textField.placeholder = "Пароль"
        
        return textField
    }()
    
    let roleTextField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        textField.placeholder = "Роль"
        
        return textField
    }()
    
    let registrationButton: UIButton = {
        let button = UIButton()
        
        button.tintColor = .label
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.layer.cornerRadius = 10
        button.alpha = 0.5
        
        return button
    }()
    
    let picker = UIPickerView()
    
    let pickerToolBar: UIToolbar = {
        let pickerToolBar = UIToolbar()
        
        pickerToolBar.barStyle = UIBarStyle.default
        pickerToolBar.isTranslucent = true
        pickerToolBar.sizeToFit()
        
        return pickerToolBar
    }()
    
    
    private func setupMainView() {
        self.view.backgroundColor = .systemBackground
    }
    
    private func constraintLoginTextField(_ textField: UITextField) {
        self.view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -115),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func constraintPasswordTextField(_ textField: UITextField) {
        self.view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func constraintRoleTextField(_ textField: UITextField) {
        self.view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -25),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func constraintRegistrationButton(_ button: UIButton) {
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 205),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func connectTextFieldWithPicker() {
        roleTextField.inputView = picker
        roleTextField.inputAccessoryView = pickerToolBar
    }
    
    private func setupUpdatedUser(_ updateUser: User?) {
        if let updateUser = updateUser {
            loginTextField.text = updateUser.authorization?.login
            passwordTextField.text = updateUser.authorization?.password
            roleTextField.text = updateUser.role.rawValue
        }
    }
}
