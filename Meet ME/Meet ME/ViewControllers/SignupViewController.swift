//
//  SignupViewController.swift
//  Meet ME
//
//  Created by Vlada on 02.01.2021.
//

import UIKit
import JGProgressHUD

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBAction func signupTouched(_ sender: UIButton) {
        let previousController = self.presentingViewController
        
        if let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let phone = phoneTextField.text, let password = passwordTextField.text {
            
            let hud = JGProgressHUD()
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            
            UserController.shared.signUpUser(phone: phone, password: password, firstName: firstName, lastName: lastName) { (success) in
                DispatchQueue.main.async {
                    if success {
                        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                        hud.dismiss(afterDelay: 2.0)
                        self.dismiss(animated: true) {
                            previousController!.performSegue(withIdentifier: "loginSegue", sender: nil)
                        }
                    } else {
                        hud.dismiss()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateUI()
    }
    
    func updateUI() {
        boxView.layer.cornerRadius = 20
        signupButton.layer.cornerRadius = 10
        firstNameTextField.layer.cornerRadius = 10
        lastNameTextField.layer.cornerRadius = 10
        phoneTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
