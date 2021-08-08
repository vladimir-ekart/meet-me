//
//  CreateViewController.swift
//  Meet ME
//
//  Created by Vlada on 12.01.2021.
//

import UIKit
import Contacts
import ContactsUI
import JGProgressHUD

class CreateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CNContactPickerDelegate {
    
    @IBOutlet var viewsCollection: [UIView]!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBAction func namefieldChanged(_ sender: Any) {
        name = nameField.text ?? ""
    }
    @IBAction func durationTouched(_ sender: UIButton) {
        datePicker.isHidden.toggle()
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        duration = Int(datePicker.countDownDuration)
        durationButton.setTitle(datePicker.countDownDuration.formattedInterval(), for: .normal)
        durationButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
    }
    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func createTouched(_ sender: UIButton) {
        if duration == 0 || users.isEmpty || name.isEmpty { return }
        
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        UserController.shared.getFree(duration: duration, users: users.map { $0.user }) { (calendar) in
            DispatchQueue.main.async {
                self.scheduleCalendar = calendar ?? []
                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                hud.dismiss(afterDelay: 2.0)
                self.performSegue(withIdentifier: "scheduleSegue", sender: nil)
            }
        }
    }
    
    static let addUserAction = Notification.Name("CreateViewController.addUserAction")
    static let showContacts = Notification.Name("CreateViewController.showContacts")
    
    var contacts: [CNContact] = []
    
    var name: String = ""
    var users: [UserMeeting] = []
    var duration = 0
    let rowHeight = 80
    var scheduleCalendar: [StartEnd] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        nameField.delegate = self
        
        let nib = UINib(nibName: "UserCell", bundle: nil)
        usersTableView.register(nib, forCellReuseIdentifier: "userCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(newUserAdded(_:)), name: CreateViewController.addUserAction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showContacts(_:)), name: CreateViewController.showContacts, object: nil)
        
        //TODO: remove when scrollview is ready
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        fetchContacts()
        updateUI()
    }
    
    func updateUI() {
        tableViewHeight.constant = CGFloat((users.count+1)*rowHeight-1)
        for view in viewsCollection {
            view.layer.cornerRadius = 20
            view.clipsToBounds = true
        }
        usersTableView.isScrollEnabled = false
        usersTableView.allowsSelection = false
        usersTableView.reloadData()
        datePicker.isHidden = true
        createButton.layer.cornerRadius = 10
    }
    
    @objc func newUserAdded(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            print(dict["phone"]!)
            let number: String = dict["phone"] as! String
            users.append(UserMeeting(status: 0, user: number))
            updateUI()
        }
    }
    
    //MARK: Contacts
    
    @objc func showContacts(_ notification: NSNotification) {
        let contactPickerVC = CNContactPickerViewController()
            contactPickerVC.delegate = self
            present(contactPickerVC, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let number: String = contact.phoneNumbers[0].value.stringValue
        if !number.isEmpty {
            users.append(UserMeeting(status: 0, user: String(number.replacingOccurrences(of: " ", with: "").suffix(9))))
            updateUI()
        }
    }
    
    func fetchContacts() {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try CNContactStore().enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                self.contacts.append(contact)
            })
        } catch let error {
            print("Failed", error)
        }
    }
    
    //MARK: Keyboard
    
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
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        if (indexPath.row == 0) {
            cell.inputCell()
            cell.inputTextField.delegate = self
        } else {
            var user = users[indexPath.row-1]
            
            let matchedArray = contacts.filter { (contact) -> Bool in
                if contact.phoneNumbers.count > 0 {
                    return contact.phoneNumbers[0].value.stringValue.replacingOccurrences(of: " ", with: "").suffix(9) == user.user
                }
                return false
            }
            
            if matchedArray.count > 0 {
                user.user = "\(matchedArray[0].givenName) \(matchedArray[0].familyName)"
            }
            
            
            cell.fillData(user)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.row != 0 {
        users.remove(at: indexPath.row-1)
        updateUI()
      }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scheduleSegue" {
            let scheduleTableViewController = segue.destination as! ScheduleTableViewController
            scheduleTableViewController.calendar = scheduleCalendar
            scheduleTableViewController.name = name
            scheduleTableViewController.users = users.map({ (user) in
                return user.user
            })
            scheduleTableViewController.duration = duration
        }
    }

}
