//
//  AuthorizationController.swift
//  rfpr
//
//  Created by poliorang on 15.05.2023.
//

import UIKit

class AuthorizationViewController: UIViewController {
    
    var services: ServicesManager! = nil
    private let alertManager = AlertManager.shared
    private let authorizationManager = AuthorizationManager.shared
    
    private var authorizationViews: AuthorizationViews! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupServices()
        authorizationViews = AuthorizationViews(view: self.view)
        
        setupTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTextInTextFields(authorizationViews.loginTextField, authorizationViews.passwordTextField)
    }
    
    private func setupServices() {
        do {
            try services = ServicesManager()
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Не удалось получить доступ к базе данных")
        }
    }
    
    private func setupDelegates() {
        authorizationViews.loginTextField.delegate = self
        authorizationViews.passwordTextField.delegate = self
    }

//    private func setupParametersTextFields(_ login: UITextField, _ password: UITextField) {
//        if let loginText = authorizationManager.getUser()?.authorization?.login,
//           let passwordText = authorizationManager.getUser()?.authorization?.password {
//            login.text = loginText
//
//            var starsText = ""
//            for _ in 0..<passwordText.count { starsText += "*" }
//            password.text = starsText
//        }
//    }
    
    private func setupTextInTextFields(_ login: UITextField, _ password: UITextField) {
        if let loginText = authorizationManager.getUser()?.authorization?.login,
           let passwordText = authorizationManager.getUser()?.authorization?.password {
            login.text = loginText
            
            var starsText = ""
            for _ in 0..<passwordText.count { starsText += "*" }
            password.text = starsText
        } else {
            login.text = ""
            password.text = ""
        }
    }
    
    private func setupTargets() {
        authorizationViews.loginWithAuthoButton.addTarget(self, action: #selector(buttonLoginWithAuthoTapped(sender:)), for: .touchUpInside)
        authorizationViews.loginWithoutAuthoButton.addTarget(self, action: #selector(buttonLoginWithoutAuthoTapped(sender:)), for: .touchUpInside)
        authorizationViews.registrationButton.addTarget(self, action: #selector(buttonRegistrationTapped(sender:)), for: .touchUpInside)
        
    }
    
    @objc
    func buttonLoginWithAuthoTapped(sender: UIButton) {
        let login = authorizationViews.loginTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        let password = authorizationViews.passwordTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        
        guard let login = login,
              let password = password else {
                  alertManager.showAlert(presentTo: self, title: "Внимание",
                                         message: "Логин и пароль не распознаны")
                  return
        }
        
        if login == "" || password == "" {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Введите логин и пароль для входа")
            return
        }
        
        let authorization = Authorization(id: nil, login: login, password: password)
        let user: User?
        do {
            user = try services.userService.getUserByAuthorization(authorization: authorization)
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Ошибка доступа к БД")
            return
        }
        
        guard let user = user else {
              alertManager.showAlert(presentTo: self, title: "Внимание",
                                     message: "Пользователь не найден")
              return
        }
        
        authorizationManager.setUser(user)
        dismiss(animated: true)
    }
    
    @objc
    func buttonLoginWithoutAuthoTapped(sender: UIButton) {
        let user: User?
        do {
            user = try services.userService.createUser(id: nil, role: .participant, authorization: nil)
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Ошибка доступа к БД")
            return
        }
        
        guard let user = user else {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Не удалось создать пользователя")
            return
        }
        
        authorizationManager.setUser(user)
        dismiss(animated: true)
    }
    
    @objc
    func buttonRegistrationTapped(sender: UIButton) {
        let dismissCompletion: () -> Void = {
            self.dismiss(animated: true)
        }
        let registrationViewController = RegistrationViewController()
        registrationViewController.gettedCompletion = dismissCompletion
        
        present(registrationViewController, animated: true, completion: nil)
       
    }
}

extension AuthorizationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {        
        return true
    }
}
