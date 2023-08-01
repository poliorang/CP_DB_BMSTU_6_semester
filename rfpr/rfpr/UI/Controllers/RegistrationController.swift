//
//  RegistrationController.swift
//  rfpr
//
//  Created by poliorang on 15.05.2023.
//

import UIKit
import RealmSwift

class RegistrationViewController: UIViewController {
    
    var services: ServicesManager! = nil
    let alertManager = AlertManager.shared
    let authorizationManager = AuthorizationManager.shared
    
    private var registrationViews: RegistrationViews! = nil
    private let roles = [Role.referee, Role.admin]
    
    var gettedCompletion: (() -> Void)? // скрытие контроллера в AuthorizationController
    var updateUser: User?               // получить из UserController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupServices()
        registrationViews = RegistrationViews(view: self.view, updateUser: updateUser)
        
        setupDelegates()
        setupTargets()
        setupPickerToolBar()
    }
    
    func setupServices() {
        do {
            try services = ServicesManager()
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Не удалось получить доступ к базе данных")
        }
    }

    private func setupDelegates() {
        registrationViews.picker.delegate = self
        registrationViews.picker.dataSource = self
    }
    
    private func setupTargets() {
        registrationViews.registrationButton.addTarget(self, action: #selector(buttonRegistrationTapped(sender:)), for: .touchUpInside)
    }
    
    private func setupPickerToolBar() {
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        registrationViews.pickerToolBar.setItems([doneButton], animated: false)
    }
    
    @objc
    func donePicker() {
        registrationViews.roleTextField.resignFirstResponder()
    }
    
    @objc
    func buttonRegistrationTapped(sender: UIButton) {
        let login = registrationViews.loginTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        let password = registrationViews.passwordTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        let role = registrationViews.roleTextField.text?.removingFinalSpaces().removingLeadingSpaces()
        
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
                
                // _ = try services.authorizationService.updateAuthorization(previousAuthorization: updateUser.authorization, newAuthorization: updatedAuthorization)
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
                                       message: "Ошибка доступа к базе данных")
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


extension RegistrationViewController: ToUserDelegateProtocol {
    // delegate
    func sendUserToRegistrationViewController(user: User?) {
        guard let user = user else {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Пользователь не распознан")
            return
        }

        self.updateUser = user
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
        return roles[row].rawValue
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        registrationViews.roleTextField.text = roles[row].rawValue
    }
}
