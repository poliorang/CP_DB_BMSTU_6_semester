//
//  RegistrationController.swift
//  rfpr
//
//  Created by poliorang on 15.05.2023.
//

import UIKit
import RealmSwift

class RegistrationViewController: UIViewController, ToUserDelegateProtocol {
    var services: ServicesManager! = nil
    let alertManager = AlertManager.shared
    let authorizationManager = AuthorizationManager.shared
    
    var gettedCompletion: (() -> Void)? // скрытие контроллера в AuthorizationController
    var updateUser: User?               // получить из UserController
    
    let roles = [Role.referee.rawValue, Role.admin.rawValue]
    
    let loginTextField = UITextField(frame: CGRect(x: 70, y: 280, width: 300, height: 40))
    let passwordTextField = UITextField(frame: CGRect(x: 70, y: 350, width: 300, height: 40))
    let roleTextField = UITextField(frame: CGRect(x: 70, y: 420, width: 300, height: 40))
    
    let picker = UIPickerView()
    let pickerToolBar = UIToolbar()
    
    let loginWithAuthoButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        
        setupServices()
        
        setupParametersTextFields(loginTextField, passwordTextField, roleTextField, picker, pickerToolBar)
        setupUpdate()
        setupPicker(picker)
        setupPickerToolBar(pickerToolBar)
        
        setupLoginWithAuthoButton(loginWithAuthoButton)
    }
    
    // delegate
    func sendUserToRegistrationViewController(user: User?) {
        guard let user = user else {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Пользователь не распознан")
            return
        }

        self.updateUser = user
    }
    
    func setupServices() {
        do {
            try services = ServicesManager()
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Не удалось получить доступ к базе данных")
        }
    }

    private func setupParametersTextFields(_ login: UITextField, _ password: UITextField, _ role: UITextField,
                                           _ picker: UIPickerView, _ toolBar: UIToolbar) {
        [login, password, role].forEach {
            view.addSubview($0)
            $0.delegate = self
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.borderStyle = UITextField.BorderStyle.roundedRect
            $0.clearButtonMode = UITextField.ViewMode.whileEditing
            if $0 == role {
                $0.inputView = picker
                $0.inputAccessoryView = toolBar
            }
        }
        login.placeholder    = "Логин"
        password.placeholder = "Пароль"
        role.placeholder     = "Роль"
    }
    
    func setupLoginWithAuthoButton(_ button: UIButton) {
        self.view.addSubview(button)
        
        button.tintColor = .label
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.layer.cornerRadius = 10
        button.alpha = 0.5
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -290),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 130),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        button.addTarget(self, action: #selector(buttonLoginWithAuthoTapped(sender:)), for: .touchUpInside)
    }
    
    private func setupPicker(_ picker: UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        
    }
    
    private func setupPickerToolBar(_ toolBar: UIToolbar) {
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        toolBar.setItems([doneButton], animated: false)
    }
    
    private func setupUpdate() {
        if let updateUser = updateUser {
            loginTextField.text = updateUser.authorization?.login
            passwordTextField.text = updateUser.authorization?.password
            roleTextField.text = updateUser.role.rawValue
        }
    }
    
    @objc
    func donePicker() {
        roleTextField.resignFirstResponder()
    }
    
    
    @objc
    func buttonLoginWithAuthoTapped(sender: UIButton) {
        let login = loginTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        let password = passwordTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        let role = roleTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        
        guard let login = login,
              let password = password,
              let role = role else {
                  alertManager.showAlert(presentTo: self, title: "Внимание",
                                         message: "Логин, пароль или роль не распознаны")
                  return
        }
        
        if login == "" || password == "" || role == "" {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Введите логин, пароль и роль")
            return
        }
        
        let authorization: Authorization?
        let user: User?
    
        // если обновление
        if let updateUser = updateUser {
            do {
                let updatedAuthorization = Authorization(id: nil, login: login, password:  password)
                let updatedUser = User(id: nil, role: Role(rawValue: role)!, authorization: updatedAuthorization)
                
//                _ = try services.authorizationService.updateAuthorization(previousAuthorization: updateUser.authorization, newAuthorization: updatedAuthorization)
                let updatedGettedUser = try services.userService.updateUser(previousUser: updateUser, newUser: updatedUser)
            } catch DatabaseError.getError {
                alertManager.showAlert(presentTo: self, title: "Внимание",
                                       message: "Пользователь с таким логином уже существует")
                return
            } catch {
                alertManager.showAlert(presentTo: self, title: "Внимание",
                                       message: "Не удалось обноваить данные о пользователе")
                return
            }
        } else {
            do {
                authorization = try services.authorizationService.createAuthorization(id: nil, login: login, password:  password)
                user = try services.userService.createUser(id: nil, role: Role(rawValue: role)!, authorization: authorization)
            } catch DatabaseError.getError {
                alertManager.showAlert(presentTo: self, title: "Внимание",
                                       message: "Пользователь с таким логином уже существует")
                return
            } catch  {
                alertManager.showAlert(presentTo: self, title: "Внимание",
                                       message: "Ошибка доступа к БД")
                return
            }
            
            guard let user = user else {
                  alertManager.showAlert(presentTo: self, title: "Внимание",
                                         message: "Пользователь не был создан")
                  return
            }
            
            authorizationManager.setUser(user)
        }
        
        dismiss(animated: true, completion: gettedCompletion)
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension RegistrationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roles.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return roles[row]
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        roleTextField.text = roles[row]
    }
}
