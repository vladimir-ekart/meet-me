//
//  DateComponentsFormatter.swift
//  Meet ME
//
//  Created by Vlada on 08.03.2021.
//

import Foundation

extension TimeInterval {
    func formattedInterval() -> String {
        let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.unitsStyle = .full

            return formatter.string(from: self)!
    }
}
