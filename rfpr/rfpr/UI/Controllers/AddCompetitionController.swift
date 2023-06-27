//
//  AddCompetitionController.swift
//  rfpr
//
//  Created by poliorang on 03.05.2023.
//

import UIKit


class AddCompetitionController: UIViewController {
    private var services: ServicesManager! = nil
    let alertManager = AlertManager.shared
    
    private var addCompetitionViews: AddCompetitionViews! = nil
    var gettedCompletion: (() -> Void)? // обновление таблицы в competitionController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        
        setupServices()
        addCompetitionViews = AddCompetitionViews(view: self.view)
        
        setupTargets()
        addCompetitionViews.nameTextField.delegate = self
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

    private func setupTargets() {
        addCompetitionViews.addCompetitionButton.addTarget(self, action: #selector(buttonAddCompetitionTapped(sender:)), for: .touchUpInside)
    }
    
    @objc
    private func buttonAddCompetitionTapped(sender: UIButton) {
        guard var competitionName = addCompetitionViews.nameTextField.text else {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Введите название соревнования")
            return
        }
        
        competitionName = competitionName.removingLeadingSpaces().removingFinalSpaces()
        
        if competitionName == "" || competitionName == " " {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Введите название соревнования")
            return
        }
        
        do {
            _ = try services.competitionService.createCompetition(id: nil, name: competitionName, teams: nil)
        } catch {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Соревнование не было создано")
            
        }
        
        dismiss(animated: true, completion: gettedCompletion)
    }
}

extension AddCompetitionController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

