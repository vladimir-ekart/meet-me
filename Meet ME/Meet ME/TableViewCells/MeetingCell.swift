//
//  MeetingCell.swift
//  Meet ME
//
//  Created by Vlada on 04.01.2021.
//

import UIKit

class MeetingCell: UITableViewCell {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarDot: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI() {
        countLabel.layer.cornerRadius = 0.5 * countLabel.bounds.size.width
        countLabel.clipsToBounds = true
    }
    
    func fillData(_ meeting: Meeting) {
        countLabel.text = String(meeting.users.count-1)
        nameLabel.text = meeting.name
        dateLabel.text = meeting.date.start.formattedString()
    }

}
