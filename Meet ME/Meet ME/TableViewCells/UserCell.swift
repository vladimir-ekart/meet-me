//
//  UserCell.swift
//  Meet ME
//
//  Created by Vlada on 07.01.2021.
//

import UIKit

class UserCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusDot: UIImageView!
    @IBOutlet weak var inputStack: UIStackView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBAction func inputTextFieldEditingChanged(_ sender: Any?) {
        let config = UIImage.SymbolConfiguration(scale: .large)
        if let phone = inputTextField.text, !phone.isEmpty {
            addButton.setImage(UIImage(systemName: "plus.circle", withConfiguration: config), for: .normal)
        } else {
            addButton.setImage(UIImage(systemName: "person.crop.circle.badge.plus", withConfiguration: config), for: .normal)
        }
    }
    @IBAction func addTouched(_ sender: UIButton) {
        inputTextField.endEditing(false)
        if let phone = inputTextField.text, !phone.isEmpty {
            if phone.isValidPhoneNumber() {
                NotificationCenter.default.post(name: CreateViewController.addUserAction, object: nil, userInfo: ["phone": inputTextField.text ?? ""])
                inputTextField.text = ""
                inputTextFieldEditingChanged(nil)
            }
        } else {
            NotificationCenter.default.post(name: CreateViewController.showContacts, object: nil, userInfo: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func inputCell() {
        showStack.isHidden = true
    }
    
    func fillData(_ user: UserMeeting) {
        inputStack.isHidden = true
        nameLabel.text = user.user
        switch user.status {
        case 0:
            statusDot.tintColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
        case 1:
            statusDot.tintColor = #colorLiteral(red: 0.1568627451, green: 0.8039215686, blue: 0.2549019608, alpha: 1)
        case 2:
            statusDot.tintColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        default:
            break
        }
    }
    
}
