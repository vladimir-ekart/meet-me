//
//  ScheduleCell.swift
//  Meet ME
//
//  Created by Vlada on 23.02.2021.
//

import UIKit

class ScheduleCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateIcon: UIImageView!
    @IBOutlet weak var appointmentsTableView: UITableView!
    @IBOutlet weak var appointmentsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var blockedLabel: UILabel!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var bodyStack: UIStackView!
    @IBOutlet weak var fullStack: UIStackView!
    @IBOutlet weak var freeStack: UIStackView!
    
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        if validate() {
            selectButton.backgroundColor = #colorLiteral(red: 0.2744791806, green: 0.2745313644, blue: 0.2787753344, alpha: 1)
        } else {
            selectButton.backgroundColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        }
    }
    
    @IBAction func startPickerChanged(_ sender: UIDatePicker) {
        let calendar = Calendar.current
        let newEnd = calendar.date(byAdding: .second, value: duration, to: startPicker.date)!
        if newEnd < data.calendar.end {
            endPicker.date = newEnd
            selectButton.backgroundColor = #colorLiteral(red: 0.2744791806, green: 0.2745313644, blue: 0.2787753344, alpha: 1)
        }
    }
    
    
    @IBAction func selectButtonTouched(_ sender: UIButton) {
        if validate() {
            NotificationCenter.default.post(name: ScheduleTableViewController.intervalSelectedAction, object: nil, userInfo: ["startEnd": StartEnd(start: startPicker.date, end: endPicker.date)])
        }
    }
    
    var data: (full: Bool, calendar: StartEnd, appointments: [(name: String, calendar: UIColor)]) = (full: true, calendar: StartEnd(start: Date(), end: Date()), appointments: [])
    var duration: Int = 0
    let rowHeight: Int = 35
    var expanded: Bool = false {
        didSet {
            bodyStack.isHidden = !expanded
            if expanded {
                setupPickers()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        appointmentsTableView.delegate = self
        appointmentsTableView.dataSource = self
        
        let nib = UINib(nibName: "AppointmentCell", bundle: nil)
        appointmentsTableView.register(nib, forCellReuseIdentifier: "appointmentCell")

        updateUI()
        appointmentsTableView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        contentView.layer.cornerRadius = 20
    }
    
    func updateUI() {
        startPicker.semanticContentAttribute = .forceRightToLeft
        startPicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        endPicker.semanticContentAttribute = .forceRightToLeft
        endPicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        timeView.layer.cornerRadius = timeView.bounds.height / 2
        selectButton.layer.cornerRadius = 10
        timeLabel.text = "\(data.calendar.start.formattedStringTime()) – \(data.calendar.end.formattedStringTime())"
        appointmentsTableViewHeight.constant = CGFloat(data.appointments.count * rowHeight)
        if data.full {
            stateIcon.image = UIImage(systemName: "xmark.circle.fill")
            stateIcon.tintColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
            timeView.backgroundColor = #colorLiteral(red: 0.8979505897, green: 0.8981013894, blue: 0.9022359252, alpha: 1)
            timeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
            stateLabel.text = "Calendar full"
            freeStack.isHidden = true
            fullStack.isHidden = false
            if data.appointments.count == 0 {
                appointmentsTableView.isHidden = true
                blockedLabel.isHidden = false
            } else {
                appointmentsTableView.isHidden = false
                blockedLabel.isHidden = true
            }
        } else {
            stateIcon.image = UIImage(systemName: "checkmark.circle.fill")
            stateIcon.tintColor = #colorLiteral(red: 0.1568627451, green: 0.8039215686, blue: 0.2549019608, alpha: 1)
            timeView.backgroundColor = #colorLiteral(red: 0.04299528152, green: 0.5177407861, blue: 0.9971262813, alpha: 1)
            timeLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            selectButton.backgroundColor = #colorLiteral(red: 0.2744791508, green: 0.2745312154, blue: 0.2744722366, alpha: 1)
            stateLabel.text = "Select time gap"
            fullStack.isHidden = true
            freeStack.isHidden = false
        }
    }
    
    func setupPickers() {
        startPicker.minimumDate = data.calendar.start
        startPicker.maximumDate = data.calendar.end
        endPicker.minimumDate = data.calendar.start
        endPicker.maximumDate = data.calendar.end
        startPicker.date = data.calendar.start
        endPicker.date = data.calendar.end
    }
    
    func validate() -> Bool {
        return startPicker.date < endPicker.date
    }
    
    func fillData(_ data: (full: Bool, calendar: StartEnd, appointments: [(name: String, calendar: UIColor)]), _ duration: Int) {
        self.data = data
        self.duration = duration
        updateUI()
        appointmentsTableView.reloadData()
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.appointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell", for: indexPath) as! AppointmentCell
        
        let appointment = data.appointments[indexPath.row]
        cell.fillData(appointment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }
    
}
