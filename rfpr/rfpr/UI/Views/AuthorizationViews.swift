//
//  AuthorizationViews.swift
//  rfpr
//
//  Created by poliorang on 27.06.2023.
//

import UIKit

class AuthorizationViews {
    private let view: UIView!
    init(view: UIView) {
        self.view = view
        
        setupMainView()
        constraintLoginTextField(loginTextField)
        constraintPasswordTextField(passwordTextField)
        constraintLoginWithAuthoButton(loginWithAuthoButton)
        constraintRegistrationButton(registrationButton)
        constraintLoginWithoutAuthoButton(loginWithoutAuthoButton)
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
    
    let loginWithAuthoButton: UIButton = {
        let button = UIButton()
        
        button.tintColor = .label
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Войти", for: .normal)
        button.layer.cornerRadius = 10
        button.alpha = 0.5
        
        return button
    }()
    
    let registrationButton: UIButton = {
        let button = UIButton()
        
        button.tintColor = .label
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Зарегистрироваться", for: .normal)
        button.layer.cornerRadius = 10
        button.alpha = 0.5
        
        return button
    }()
    
    let loginWithoutAuthoButton: UIButton = {
        let button = UIButton()
        
        button.tintColor = .label
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Войти без регистрации", for: .normal)
        button.layer.cornerRadius = 10
        button.alpha = 0.5
        
        return button
    }()
    
    
    private func setupMainView() {
        self.view.backgroundColor = .systemBackground
    }
    
    private func constraintLoginTextField(_ textField: UITextField) {
        self.view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -65),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func constraintPasswordTextField(_ textField: UITextField) {
        self.view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func constraintLoginWithAuthoButton(_ button: UIButton) {
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 160),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 35),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
    
    private func constraintLoginWithoutAuthoButton(_ button: UIButton) {
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -85),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 205),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
