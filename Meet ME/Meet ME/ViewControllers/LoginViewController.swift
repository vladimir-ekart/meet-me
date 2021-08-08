//
//  LoginViewController.swift
//  Meet ME
//
//  Created by Vlada on 02.01.2021.
//

import UIKit
import JGProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginTouched(_ sender: UIButton) {
        if let phone = phoneTextField.text, let password = passwordTextField.text {
            
            let hud = JGProgressHUD()
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            
            UserController.shared.loginUser(phone: phone, password: password) { (success) in
                DispatchQueue.main.async {
                    if (success) {
                        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                        hud.dismiss(afterDelay: 2.0)
                        self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    } else {
                        hud.dismiss()
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateUI()
        
        UserController.shared.loadToken()
        if UserController.shared.hasToken() {
            self.loginWihtToken()
        }
    }
    
    func updateUI() {
        boxView.layer.cornerRadius = 20
        loginButton.layer.cornerRadius = 10
        phoneTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/3
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
    
    func loginWihtToken() {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Logging in"
        hud.show(in: self.view)
        
        UserController.shared.getUser { (success) in
            DispatchQueue.main.async {
                if (success) {
                    hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    hud.dismiss(afterDelay: 2.0)
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                } else {
                    hud.dismiss()
                }
            }
        }
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
