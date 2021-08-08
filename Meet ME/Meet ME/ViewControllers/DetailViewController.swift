//
//  DetailViewController.swift
//  Meet ME
//
//  Created by Vlada on 05.01.2021.
//

import UIKit
import EventKit
import EventKitUI
import Contacts
import JGProgressHUD

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, EKEventEditViewDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet var viewsCollection: [UIView]!
    @IBOutlet var actionButtons: [UIButton]!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBAction func acceptTouched(_ sender: UIButton) {
        response(1)
    }
    @IBAction func rejectTouched(_ sender: UIButton) {
        response(2)
    }
    @IBAction func deleteTouched(_ sender: UIBarButtonItem) {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Deleting"
        hud.show(in: self.view)
        
        UserController.shared.deleteMeeting(meeting: meeting.id) {
            DispatchQueue.main.async {
                hud.dismiss(afterDelay: 2.0)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    @IBAction func Addtocalendar(_ sender: UIButton) {
        self.eventStore.requestAccess(to: .event) { (granted, error) in
          
          if (granted) && (error == nil) {
            print("calendar OK")
              
            let event = self.generateEvent()
            
            print("event OK")
            self.showInvite(event)
          }
          else{
            print("calendar FAILED")
          }
        }
    }
    
    func showInvite(_ event: EKEvent){
        DispatchQueue.main.async {
            let eventVC = EKEventEditViewController()
            eventVC.editViewDelegate = self
            eventVC.eventStore = self.eventStore
            eventVC.event = event
            self.present(eventVC, animated: true, completion: nil)
        }
    }
    
    private func generateEvent() -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = meeting.name
        newEvent.startDate = meeting.date.start
        newEvent.endDate = meeting.date.end
        return newEvent
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)
    }
    
    func response(_ status: Int) {
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        UserController.shared.responseMeeting(id: self.meeting.id, status: status) { (success) in
            DispatchQueue.main.async {
                if success {
                    hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    hud.dismiss(afterDelay: 2.0)
                    self.user?.status = status
                    self.updateUI()
                } else {
                    hud.dismiss(afterDelay: 2.0)
                }
            }
        }
    }
    
    
    var meeting: Meeting!
    var user: UserMeeting?
    var rowHeight = 80
    let eventStore = EKEventStore()
    var contacts: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        let nib = UINib(nibName: "UserCell", bundle: nil)
        usersTableView.register(nib, forCellReuseIdentifier: "userCell")
        
        user = meeting.users.first(where: { (slot) -> Bool in
            return slot.user == UserController.shared.user?.phone
        })
        
        fetchContacts()
        updateUI()
        fillData()
        usersTableView.reloadData()
    }
    
    func updateUI() {
        tableViewHeight.constant = CGFloat((meeting.users.count)*rowHeight-1)
        for view in viewsCollection {
            view.layer.cornerRadius = 20
            view.clipsToBounds = true
        }
        for button in actionButtons {
            button.layer.cornerRadius = 10
        }
        usersTableView.isScrollEnabled = false
        usersTableView.allowsSelection = false 
        usersTableView.reloadData()
        if meeting.owner != UserController.shared.user?.phone {
            deleteButton.isEnabled = false
            deleteButton.tintColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        }
        
        if (user?.status == 1) {
            actionButtons[0].isHidden = true
            actionButtons[1].isHidden = true
            actionButtons[2].isHidden = false
        } else if (user?.status == 0) {
            actionButtons[0].isHidden = false
            actionButtons[1].isHidden = false
            actionButtons[2].isHidden = true
        } else {
            actionButtons[0].isHidden = true
            actionButtons[1].isHidden = true
            actionButtons[2].isHidden = true
        }
        switch user?.status {
        case 0:
            statusLabel.text = "Pending"
        case 1:
            statusLabel.text = "Ready"
        case 2:
            statusLabel.text = "Denied"
        default:
            break
        }
    }
    
    func fillData() {
        startLabel.text = meeting.date.start.formattedStringLong()
        endLabel.text = meeting.date.end.formattedStringLong()
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
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meeting.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        var user = meeting.users[indexPath.row]
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
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
