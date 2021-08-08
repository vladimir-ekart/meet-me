//
//  ScheduleTableViewController.swift
//  Meet ME
//
//  Created by Vlada on 16.02.2021.
//

import UIKit
import EventKit
import JGProgressHUD

class ScheduleTableViewController: UITableViewController {

    @IBOutlet var scheduleTableView: UITableView!
    
    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    static let intervalSelectedAction = Notification.Name("ScheduleTableViewController.intervalSelectedAction")
    
    var name: String!
    var users: [String]!
    var calendar: [StartEnd]!
    var duration: Int!
    var processedCalendar: [(name: String,
                             events: [(full: Bool,
                                       calendar: StartEnd,
                                       appointments: [(name: String, calendar: UIColor)])])] = []
    var finalMeeting: Meeting?
    var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "ScheduleCell", bundle: nil)
        scheduleTableView.register(nib, forCellReuseIdentifier: "scheduleCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(intervalSelected(_:)), name: ScheduleTableViewController.intervalSelectedAction, object: nil)
        
        processCalendar()
    }
    
    @objc func intervalSelected(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let interval: StartEnd = dict["startEnd"] as! StartEnd
            
            let hud = JGProgressHUD()
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            
            UserController.shared.createMeeting(name: name, start: interval.start, end: interval.end, users: users) { (meeting) in
                DispatchQueue.main.async {
                    
                    self.finalMeeting = meeting
                    if self.finalMeeting != nil {
                        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                        hud.dismiss(afterDelay: 2.0)
                        self.performSegue(withIdentifier: "detailSegue", sender: nil)
                    } else {
                        hud.dismiss(afterDelay: 2.0)
                    }
                }
            }
        }
    }
    
    func processCalendar() {
        var fullCalendar: [(full: Bool, calendar: StartEnd, appointments: [(name: String, calendar: UIColor)])] = []
        let appointments = getAppointments(start: calendar.first?.end ?? Date(), end: calendar.last?.start ?? Date())
        for (index, event) in calendar.enumerated() {
            fullCalendar.append((full: false, calendar: event, appointments: []))
            if index+1 < calendar.count {
                fullCalendar.append((full: true, calendar: StartEnd(start: event.end, end: calendar[index+1].start), appointments: appointments.filter{$0.start >= event.end && $0.end <= calendar[index+1].start}.map{(name: $0.name, calendar: $0.calendar)}))
            }
        }
        var endDate = Calendar(identifier: .gregorian).startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        var section: (name: String, events: [(full: Bool, calendar: StartEnd, appointments: [(name: String, calendar: UIColor)])]) = (name: "Today", events: [])
        for event in fullCalendar {
            if endDate < event.calendar.start {
                processedCalendar.append(section)
                endDate = Calendar(identifier: .gregorian).startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: event.calendar.start)!)
                section = (name: event.calendar.start.formattedString(), events: [])
            }
            section.events.append(event)
        }
        if processedCalendar.first?.events.count ?? -1 == 0 {
            processedCalendar.remove(at: 0)
        }
    }
    
    func getAppointments(start: Date, end: Date) -> [(name: String, calendar: UIColor, start: Date, end: Date)] {
        var events: [EKEvent] = []
        
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
    
        let eventsPredicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        events.append(contentsOf: eventStore.events(matching: eventsPredicate))
        
        return events.map({ (e) in
            return (name: e.title, calendar: UIColor(cgColor: e.calendar.cgColor), start: e.startDate, end: e.endDate)
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return processedCalendar.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return processedCalendar[section].name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return processedCalendar[section].events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleCell
        
        let event = processedCalendar[indexPath.section].events[indexPath.row]
        cell.fillData(event, duration)
        
        cell.selectionStyle = .none
        cell.expanded = indexPath == selectedIndex
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if selectedIndex == indexPath {
            selectedIndex = nil
        } else {
            selectedIndex = indexPath
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndex {
            let event = processedCalendar[indexPath.section].events[indexPath.row]
            if event.full {
                if event.appointments.isEmpty {
                    return 160
                } else {
                    return CGFloat(120 + event.appointments.count*35)
                }
            } else {
                return 280
            }
        }
        return 89
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.meeting = finalMeeting
        }
    }
    

}
