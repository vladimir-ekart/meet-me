//
//  UserViewController.swift
//  Meet ME
//
//  Created by Vlada on 02.01.2021.
//

import UIKit
import SPPermissions

class UserViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var permissionsView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var permissionsButton: UIButton!
    
    @IBAction func logoutTouched(_ sender: UIButton) {
        UserController.shared.logoutUser()
        self.performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    @IBAction func permissionsTouched(_ sender: UIButton) {
        showPermissions()
    }
    
    private var calendar = SPPermission.calendar.isAuthorized {
        didSet {
            self.setPermissionLabel()
        }
    }
    private var contacts = SPPermission.contacts.isAuthorized {
        didSet {
            self.setPermissionLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        fillData()
    }
    
    func updateUI() {
        logoutButton.layer.cornerRadius = 10
        permissionsView.layer.cornerRadius = 15
        permissionsButton.layer.cornerRadius = permissionsButton.bounds.height / 2
        setPermissionLabel()
    }
    
    func fillData() {
        let user = UserController.shared.user
        nameLabel.text = "\(user!.firstName) \(user!.lastName)"
        phoneLabel.text = user!.phone
    }
    
    func setPermissionLabel() {
        if (calendar && contacts) {
            permissionsButton.setTitle("   ALLOWED   ", for: .normal)
            permissionsButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            permissionsButton.backgroundColor = #colorLiteral(red: 0.04299528152, green: 0.5177407861, blue: 0.9971262813, alpha: 1)
        } else {
            permissionsButton.setTitle("     REQUIRED    ", for: .normal)
            permissionsButton.setTitleColor(#colorLiteral(red: 0.04299528152, green: 0.5177407861, blue: 0.9971262813, alpha: 1), for: .normal)
            permissionsButton.backgroundColor = #colorLiteral(red: 0.9332415462, green: 0.9333980083, blue: 0.9418292642, alpha: 1)
        }
    }
    
    func showPermissions() {
        let controller = SPPermissions.list([.calendar, .contacts])
        // Always use this method for present
        controller.present(on: self)
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
