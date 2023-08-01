//  ViewController.swift
//  rfpr
//
//  Created by poliorang on 28.03.2023.
//

import UIKit
import RealmSwift

protocol CompetitionToTeamDelegateProtocol {
    func sendCompetitionToTeamViewController(competition: Competition?)
}

class CompetitionViewController: UIViewController {
    var services: ServicesManager! = nil
    let alertManager = AlertManager.shared
    let authorizationManager = AuthorizationManager.shared
    
    typealias CompetitionTableViewCell = UITableViewCell
    var competitionDelegate: CompetitionToTeamDelegateProtocol? = nil
    
    private var competitionViews: CompetitionViews! = nil
    private let authorizationViewController = AuthorizationViewController()

    var competitions = [Competition]()
    
    let tableView = UITableView.init(frame: .zero, style: UITableView.Style.grouped)
    private var accountBarButton: UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupServices()
        getCompetitions()
        
        setupNavigation()
        setupTable()
        setupBarButtons()
        
        competitionViews = CompetitionViews(view: self.view)
        setupTargets()
        
        present(authorizationViewController, animated: true, completion: nil)
    }
    
    private func setupServices() {
        do {
            try services = ServicesManager()
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Не удалось получить доступ к базе данных")
        }
    }
    
    private func getCompetitions() {
        do {
            try competitions = services.competitionService.getCompetitions() ?? []
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "В базе данных нет ни одного соревнования")
        }
    }
    
    private func setupNavigation() {
        self.navigationItem.title = "Соревнования"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        
        tableView.register(CompetitionTableViewCell.self, forCellReuseIdentifier: "CompetitionTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.frame = CGRect.init(origin: .zero, size: self.view.frame.size)
    }
    
    private func setupBarButtons() {
        self.accountBarButton = UIBarButtonItem(title: "Аккаунт", style: UIBarButtonItem.Style.done,
                                                    target: self, action: #selector(buttonAccountTapped(_:)))
        self.navigationItem.rightBarButtonItem = self.accountBarButton
        
        self.accountBarButton = UIBarButtonItem(title: "  🛠️", style: UIBarButtonItem.Style.done,
                                                    target: self, action: #selector(buttonSetupsTapped(_:)))
        self.navigationItem.leftBarButtonItem = self.accountBarButton
    }

    private func setupTargets() {
        competitionViews.competitionButton.addTarget(self, action: #selector(buttonAddCompetitionTapped(sender:)), for: .touchUpInside)
    }
    
    @objc
    private func buttonSetupsTapped(_ sender: UIBarButtonItem) {
        if !authorizationManager.getRight(true) {
            alertManager.showAlert(presentTo: self, title: "Доступ запрещен",
                                   message: "Доступ разрешен только для администратора")
            return
        }
        
        let usersViewController = UsersViewController()
        present(usersViewController, animated: true, completion: nil)
    }
    
    @objc
    private func buttonAccountTapped(_ sender: UIBarButtonItem) {
        present(authorizationViewController, animated: true, completion: nil)
    }
    
    @objc
    private func buttonAddCompetitionTapped(sender: UIButton) {
        if !authorizationManager.getRight() {
            alertManager.showAlert(presentTo: self, title: "Доступ запрещен",
                                   message: "Неавторизованные пользователи не могут создавать соревнования")
            return
        }
        
        let updateTableCompletion:() -> Void = {
            self.getCompetitions()
            self.tableView.reloadData()
        }
        
        let addCompetitionController = AddCompetitionController()
        addCompetitionController.gettedCompletion = updateTableCompletion
        present(addCompetitionController, animated: true, completion: nil)
    }
}
