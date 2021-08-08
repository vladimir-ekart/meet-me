//
//  User.swift
//  Meet ME
//
//  Created by Vlada on 31.12.2020.
//

import Foundation

struct User: Codable {
    let id: String
    var firstName: String
    var lastName: String
    let phone: String
    var meetings: [Meeting]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName = "firstname"
        case lastName = "lastname"
        case phone
        case meetings
    }
}

struct CalendarModel: Codable {
    var calendar: [StartEnd]
    
    init (calendar: [StartEnd]) {
        var sorted: [StartEnd] = []
        var all: [(date: Date, start: Bool)] = []
        for event in calendar {
            all.append((date: event.start, start: true))
            all.append((date: event.end, start: false))
        }
        all.append((date: Date(), start: false))
        all.append((date: Calendar.current.date(byAdding: .month, value: 1, to: Date())!, start: true))
        var active = 1
        var start: Date = Date()
        for item in all.sorted(by: { (a, b) -> Bool in
            return a.date < b.date
        }) {
            if !item.start {
                active -= 1
                if active == 0 {
                    start = item.date
                }
            } else {
                if active == 0 {
                    sorted.append(StartEnd(start: start, end: item.date))
                }
                active += 1
            }
        }
        self.calendar = sorted
    }
    
    enum CodingKeys: String, CodingKey {
        case calendar = "calendar"
    }   
}

struct Token: Codable {
    let token: String
}
