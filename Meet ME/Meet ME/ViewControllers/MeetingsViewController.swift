//
//  MeetingsViewController.swift
//  Meet ME
//
//  Created by Vlada on 03.01.2021.
//

import UIKit
import SPPermissions

class MeetingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var meetingsTableView: UITableView!
    @IBOutlet weak var meetingsView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBAction func indexChanged(_ sender: Any) {
        typeIndex = segmentControl.selectedSegmentIndex
        switch typeIndex {
        case 0:
            typeLabel.text = "Scheduled"
        case 1:
            typeLabel.text = "Pending"
        case 2:
            typeLabel.text = "Denied"
        default:
            break
        }
        updateUI()
    }
    
    @IBAction func unwindToMeetings(_ unwindSegue: UIStoryboardSegue) {
        divideInCategories()
        meetingsTableView.reloadData()
        updateUI()
    }
    
    let rowHeight = 80
    var meetings: [[Meeting]] = [[],[],[]]
    var typeIndex = 0
    var showEmpty = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        meetingsTableView.delegate = self
        meetingsTableView.dataSource = self
        
        divideInCategories()
        
        let nib = UINib(nibName: "MeetingCell", bundle: nil)
        meetingsTableView.register(nib, forCellReuseIdentifier: "meetingCell")
        
        let nibE = UINib(nibName: "EmptyCell", bundle: nil)
        meetingsTableView.register(nibE, forCellReuseIdentifier: "emptyCell")
        
        updateUI()
        checkForPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        divideInCategories()
        updateUI()
    }
    
    func updateUI() {
        showEmpty = meetings[typeIndex].count == 0
        if (showEmpty) {
            tableViewHeight.constant = CGFloat(rowHeight-1)
        } else {
            tableViewHeight.constant = CGFloat(meetings[typeIndex].count*rowHeight-1)
        }
        meetingsView.layer.cornerRadius = 20
        meetingsView.clipsToBounds = true
        meetingsTableView.isScrollEnabled = false
        meetingsTableView.reloadData()
    }
    
    func divideInCategories() {
        let allMeetings: [Meeting] = UserController.shared.getMeetings()
        let me = UserController.shared.user
        meetings[0] = allMeetings.filter{ (Meeting) -> Bool in
            for user in Meeting.users {
                if user.user == me?.phone && user.status == 1 {
                    return true
                }
            }
            return false
        }
        meetings[1] = allMeetings.filter{ (Meeting) -> Bool in
            for user in Meeting.users {
                if user.user == me?.phone && user.status == 0 {
                    return true
                }
            }
            return false
        }
        meetings[2] = allMeetings.filter{ (Meeting) -> Bool in
            for user in Meeting.users {
                if user.user == me?.phone && user.status == 2 {
                    return true
                }
            }
            return false
        }
    }
    
    func checkForPermissions() {
        if (!SPPermission.calendar.isAuthorized && !SPPermission.contacts.isAuthorized) {
            let controller = SPPermissions.dialog([.calendar, .contacts])
            // Always use this method for present
            controller.present(on: self)
        }
    }
    
    //MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (showEmpty) {
            return 1
        } else {
            return meetings[typeIndex].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (showEmpty) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath) as! MeetingCell
        
        let sectionMeetings = meetings[typeIndex]
        let meeting = sectionMeetings[indexPath.row]
        
        cell.fillData(meeting)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "mainDetailSegue", sender: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainDetailSegue" {
            let detailViewController = segue.destination as! DetailViewController
            let index = meetingsTableView.indexPathForSelectedRow!.row
            let sectionMeetings = meetings[typeIndex]
            let meeting = sectionMeetings[index]
            detailViewController.meeting = meeting
        }
    }
    

}
