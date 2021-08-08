//
//  AppointmentCell.swift
//  Meet ME
//
//  Created by Vlada on 09.03.2021.
//

import UIKit

class AppointmentCell: UITableViewCell {
    
    @IBOutlet weak var calendarDot: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func fillData(_ appointment: (name: String, calendar: UIColor)) {
        calendarDot.tintColor = appointment.calendar
        titleLabel.text = appointment.name
    }
}
