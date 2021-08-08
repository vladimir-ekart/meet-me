//
//  Date.swift
//  Meet ME
//
//  Created by Vlada on 04.01.2021.
//

import Foundation

extension Date {
    func formattedString() -> String {
        if Calendar(identifier: .gregorian).isDateInToday(self) {
            return "Today"
        } else if Calendar(identifier: .gregorian).isDateInTomorrow(self) {
            return "Tomorrow"
        }
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd yyyy"
        
        return dateFormatterPrint.string(from: self)
    }
    func formattedStringTime() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "HH:mm"
        
        return dateFormatterPrint.string(from: self)
    }
    func formattedStringLong() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd yyyy HH:mm"
        
        return dateFormatterPrint.string(from: self)
    }
}
