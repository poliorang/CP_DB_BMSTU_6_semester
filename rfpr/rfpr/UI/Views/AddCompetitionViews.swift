//
//  AddCompetitionViews.swift
//  rfpr
//
//  Created by poliorang on 26.06.2023.
//

import UIKit

class AddCompetitionViews {
    private let view: UIView!
    init(view: UIView) {
        self.view = view
        
        setupMainView()
        constraintNameLabel(nameLabel)
        constraintTextField(nameTextField)
        constraintAddCompetitionButton(addCompetitionButton)
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
    
        label.text = "Название соревнования"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "Название соревнования"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.enablesReturnKeyAutomatically = false
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        return textField
    }()
    
    let addCompetitionButton: UIButton = {
        let button = UIButton()
        
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setImage(UIImage(systemName: "plus")!, for: .normal)
        button.layer.cornerRadius = 10
        button.alpha = 0.5
        
        return button
    }()
    
    
    private func setupMainView() {
        self.view.backgroundColor = .systemBackground
    }
    
    
    private func constraintNameLabel(_ label: UILabel) {
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func constraintTextField(_ textField: UITextField) {
        self.view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -15),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func constraintAddCompetitionButton(_ button: UIButton) {
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 110),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
