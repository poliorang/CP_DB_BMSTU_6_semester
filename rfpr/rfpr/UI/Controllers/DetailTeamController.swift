//
//  DetailTeamViewController.swift
//  rfpr
//
//  Created by poliorang on 07.05.2023.
//

import UIKit

class DetailTeamViewController: UIViewController, ToDetailTeamDelegateProtocol,
                                ToDetailTeamtUpdateDelegateProtocol {
    var services: ServicesManager! = nil
    let alertManager = AlertManager.shared
    let authorizationManager = AuthorizationManager.shared
    
    let nameLabel = UILabel(frame: CGRect(x: 20, y: 70, width: 320, height: 40))
    let nameTextField = UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
    
    let firstParticipantTextField = UITextField(frame: CGRect(x: 20, y: 300, width: 300, height: 40))
    var secondParticipantTextField = UITextField(frame: CGRect(x: 20, y: 370, width: 300, height: 40))
    let thirdParticipantTextField = UITextField(frame: CGRect(x: 20, y: 440, width: 300, height: 40))
    
    let toolBar = UIToolbar()
    let participantPicker = UIPickerView()
    
    let createTeamButton = UIButton()
    
    var selectedTextField: UITextField? = nil
    var participants = [Participant]()
    var competition: Competition?       // получить из TeamController
    var updateTeam: Team? // получить из TeamController
    var firstlyParticipants: [Participant]? // участники перед редактированием
    
    var gettedCompletion: (() -> Void)? // обновление таблицы в TeamController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }

        guard let _ = competition else {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Соревнование не распознано")
            return
        }
        
        setupServices()
        getParticipants()

        setupNameLabel(nameLabel)
        setupNameTextField(nameTextField)
        
        setupParticipantPicker(participantPicker)
        setupToolBar(toolBar)

        setupParticipantsTextFields(firstParticipantTextField,
                                    secondParticipantTextField,
                                    thirdParticipantTextField,
                                    participantPicker, toolBar)
        setupCreateTeamButton(createTeamButton)
        
        setupUpdate()
        
        createTeamButton.addTarget(self, action: #selector(buttonCreateTeamTapped(sender:)), for: .touchUpInside)
    }
    
    func sendTeamToTeamViewController(team: Team?) {
        guard let team = team else {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Команда не распознана")
            return
        }

        self.updateTeam = team
    }
    
    func sendCompetitionToTeamViewController(competition: Competition?) {
        guard let competition = competition else {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Соревнование не распознано")
            return
        }

        self.competition = competition
    }

    private func setupServices() {
        do {
            try services = ServicesManager()
        } catch {
            alertManager.showAlert(presentTo: self, title: "Внимание",
                                   message: "Не удалось получить доступ к базе данных")
        }
    }
    
    func setupUpdate() {
        
        if let updateTeam = updateTeam {
            firstlyParticipants = try? services.participantService.getParticipantByTeam(team: updateTeam)

            nameTextField.text = updateTeam.name
            
            let participantsByTeam: [Participant]?
            do {
                participantsByTeam = try services.participantService.getParticipantByTeam(team: updateTeam)
            } catch {
                alertManager.showAlert(presentTo: self, title: "Внимание",
                                       message: "Не удалось найти участников команды")
                return
            }
            
            if let participantsByTeam = participantsByTeam {
                firstParticipantTextField.text = 0 < participantsByTeam.count ?
                                                participantsByTeam[0].lastName + " " + participantsByTeam[0].firstName : ""
                secondParticipantTextField.text = 1 < participantsByTeam.count ?
                                                participantsByTeam[1].lastName + " " + participantsByTeam[1].firstName : ""
                thirdParticipantTextField.text = 2 < participantsByTeam.count ?
                                                participantsByTeam[2].lastName + " " + participantsByTeam[2].firstName : ""
            }
        }
    }
    
    private func getParticipants() {
        do {
            try participants = services.participantService.getParticipants() ?? []
        } catch {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "В базе данных нет ни одной команды")
        }
    }
    
    private func setupNameLabel(_ label: UILabel) {
        self.view.addSubview(label)
    
        label.textAlignment = .left
        label.text = "Название команды"
    }
    
    private func setupNameTextField(_ textField: UITextField) {
        self.view.addSubview(nameTextField)
        
        textField.placeholder = "Ведите название команды"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        textField.delegate = self
    }

    private func setupParticipantsTextFields(_ first: UITextField, _ second: UITextField, _ third: UITextField, _ picker: UIPickerView, _ toolBar: UIToolbar) {
        [first, second, third].forEach {
            view.addSubview($0)
            $0.delegate = self
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.borderStyle = UITextField.BorderStyle.roundedRect
            $0.clearButtonMode = UITextField.ViewMode.whileEditing
            $0.inputView = picker
            $0.inputAccessoryView = toolBar
        }
        
        first.placeholder = "Первый участник"
        second.placeholder = "Второй участник"
        third.placeholder = "Третий участник"
    }
    
    
    private func setupParticipantPicker(_ picker: UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        
    }
    
    private func setupToolBar(_ toolBar: UIToolbar) {
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        toolBar.setItems([doneButton], animated: false)
    }
    
    private func setupCreateTeamButton(_ button: UIButton) {
        view.addSubview(button)
        
        if #available(iOS 13.0, *) {
            button.tintColor = .label
        } else {
            // Fallback on earlier versions
        }
        
        button.backgroundColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "plus")!, for: .normal)
        } else {
            // Fallback on earlier versions
        }
        
        button.layer.cornerRadius = 10
        button.alpha = 0.5
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 110),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func getParticipantsFromTextFields() -> [Participant]? {
        var participant1: Participant?
        var participant2: Participant?
        var participant3: Participant?
        
        if let firstText = firstParticipantTextField.text {
            if firstText.isEmpty == false {
                participant1 = try? services.participantService.getParticipant(fullname: firstText)?.first
            }
        }
        
        if let secondText = secondParticipantTextField.text {
            if secondText.isEmpty == false {
                participant2 = try? services.participantService.getParticipant(fullname: secondText)?.first
            }
        }
        
        if let thirdText = thirdParticipantTextField.text {
            if thirdText.isEmpty == false {
                participant3 = try? services.participantService.getParticipant(fullname: thirdText)?.first
            }
        }
        
        var resultParticipants = [Participant]()
        [participant1, participant2, participant3].forEach {
            if let participant = $0 {
                resultParticipants.append(participant)
            }
        }
        
        return resultParticipants.isEmpty ? nil : resultParticipants
    }
    
    @objc
    func donePicker() {
        selectedTextField?.resignFirstResponder()
    }
    
    @objc
    func buttonCreateTeamTapped(sender: UIButton) {
        if !authorizationManager.getRight() {
            alertManager.showAlert(presentTo: self, title: "Доступ запрещен",
                                   message: "Неавторизованные пользователи не могут формировать")
            return
        }
        
        var team: Team? = nil
        guard var teamName = nameTextField.text else {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Введите название команды")
            return
        }
        if teamName == "" || teamName == " " {
            alertManager.showAlert(presentTo: self,
                                   title: "Внимание",
                                   message: "Введите название команды")
            return
        }
        
        teamName = teamName.removingLeadingSpaces().removingFinalSpaces()
        let participantOfCreatedTeam = getParticipantsFromTextFields()
        
        
        if let updateTeam = updateTeam {
            do {
                let newTeam = Team(id: nil, name: teamName, competitions: nil, score: 0)
                team = try services.teamService.updateTeam(previousTeam: updateTeam, newTeam: newTeam)
                
                for participant in participantOfCreatedTeam ?? [] {
                    try services.teamService.addParticipant(participant: participant, team: team)
                }
                try services.teamService.addCompetition(team: team, competition: competition)
                
                // если есть участники, которых удалили из команды
                let deletedParticipants = Set(firstlyParticipants ?? []).subtracting(Set(participantOfCreatedTeam ?? []))
                if deletedParticipants.isEmpty == false {
                    for participant in deletedParticipants {
                        let newParticipant = Participant(id: participant.id, lastName: participant.lastName, firstName: participant.firstName, patronymic: participant.patronymic, team: nil, city: participant.city, birthday: participant.birthday, score: participant.score)
                        do {
                            _ = try services.participantService.updateParticipant(previousParticipant: participant, newParticipant: newParticipant)
                        } catch {
                            alertManager.showAlert(presentTo: self,
                                                   title: "Внимание",
                                                   message: "Не удалось удалить участника из команды")
                        }
                    }
                }
                
            } catch {
                alertManager.showAlert(presentTo: self, title: "Внимание",
                                       message: "Команда не была обновлена")
            }
            
        } else {
            do {
                try team = services.teamService.createTeam(id: nil, name: teamName, competitions: [competition!], score: 0)
                for participant in participantOfCreatedTeam ?? [] {
                    try services.teamService.addParticipant(participant: participant, team: team)
                }
                
            } catch {
                alertManager.showAlert(presentTo: self, title: "Внимание",
                                       message: "Команда не была создано")
                
            }
        }
        
        dismiss(animated: true, completion: gettedCompletion)
    }
}

extension DetailTeamViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return participants.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var returnString = "\(participants[row].lastName) \(participants[row].firstName)"
        
        if let patronymic = participants[row].patronymic {
            returnString = "\(participants[row].lastName) \(participants[row].firstName) \(patronymic)"
        }
        
        return returnString
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {        
        var selectedData = "\(participants[row].lastName) \(participants[row].firstName)"
        
        if let patronymic = participants[row].patronymic {
            selectedData = "\(participants[row].lastName) \(participants[row].firstName) \(patronymic)"
        }
        if let selectedTextField = selectedTextField {
            selectedTextField.text = selectedData
        }
    }
}

//extension UITextField {
//    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(copy(_:)) || action == #selector(paste(_:)) {
//            return false
//        }
//        return true
//    }
//}

extension DetailTeamViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.selectedTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
