//
//  UsersController.swift
//  rfpr
//
//  Created by poliorang on 20.05.2023.
//

import UIKit

protocol ToUserDelegateProtocol {
    func sendUserToRegistrationViewController(user: User?)
}

class UsersViewController: UIViewController {
    typealias UserTableViewCell = UITableViewCell
    
    var services: ServicesManager! = nil
    let alertManager = AlertManager.shared
    let authorizationManager = AuthorizationManager.shared
    
    var toUserDelegateProtocol: ToUserDelegateProtocol? = nil
    
    var users = [User]()
    
    let tableView = UITableView.init(frame: .zero, style: UITableView.Style.grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupServices()
        getUsers()
        setupTable()
    }
    
    private func setupServices() {
        do {
            try services = ServicesManager()
        } catch {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Не удалось получить доступ к базе данных")
        }
    }
    
    private func getUsers() {
        do {
            try users = services.userService.getAuthorizedUsers() ?? []
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "В базе данных нет ни одного пользователя")
        }
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.frame = CGRect.init(origin: .zero, size: self.view.frame.size)
    }
}


extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tableView:
            return self.users.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)
        cell.textLabel?.text = self.users[indexPath.row].authorization!.login + " " + self.users[indexPath.row].role.rawValue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

            let cell = tableView.cellForRow(at: indexPath)!
            var user: User?
            do {
                var login = cell.textLabel?.text?.components(separatedBy: " ").first
                if let _ = login {
                    login = login!.removingLeadingSpaces().removingFinalSpaces()
                }
                
                user = try services.userService.getUserByLogin(login!)
            } catch {
                alertManager.showAlert(presentTo: self,
                                       title: "Внимание",
                                       message: "Не найден пользователь")
                return
            }
            
            
            // если админ пытается удалить свой акк, то ему выдаются права неавториз пользователя после удаления
            if user == authorizationManager.getUser() {
                let newUser = try? services.userService.createUser(id: nil, role: .participant, authorization: nil)
                if let newUser = newUser {
                    authorizationManager.setUser(newUser)
                } else {
                    alertManager.showAlert(presentTo: self,
                                           title: "Внимание",
                                           message: "Вы удаляете свой аккаунт. Не удалось переопределить ваши права пользования.")
                    return
                }
            }

            do {
                try services.userService.deleteUser(user: user)
            } catch {
                alertManager.showAlert(presentTo: self,
                                       title: "Внимание",
                                       message: "Не удалось удалить пользователя")
            }

            tableView.beginUpdates()
            users.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()

            if users.count <= 0 {
                alertManager.showAlert(presentTo: self,
                                       title: "Внимание",
                                       message: "Не создан ни один пользователь")
            }
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!)!

        let registrationViewController = RegistrationViewController()
        toUserDelegateProtocol = registrationViewController

        var user: User?
        do {
            var login = cell.textLabel?.text?.components(separatedBy: " ").first
            if let _ = login {
                login = login!.removingLeadingSpaces().removingFinalSpaces()
            }
            
            user = try services.userService.getUserByLogin(login!)
        } catch {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Не найден пользователь")
            return
        }
        
        let updateCompletion: () -> Void = {
            self.getUsers()
            self.tableView.reloadData()
        }
        
        registrationViewController.gettedCompletion = updateCompletion
        toUserDelegateProtocol?.sendUserToRegistrationViewController(user: user)
        present(registrationViewController, animated: true, completion: nil)
    }
}
