//
//  UserController.swift
//  Meet ME
//
//  Created by Vlada on 31.12.2020.
//

import Foundation
import EventKit

class UserController {
    
    var user: User?
    static let shared = UserController()
    private let baseURL = URL(string: "https://ekart-meet-me.herokuapp.com/api/")!
    private var token: String?
    
    func getMeetings() -> [Meeting] {
        return user?.meetings ?? []
    }
    
    func hasToken() -> Bool {
        return self.token != nil && self.token != ""
    }
    
    func signUpUser(phone: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool) -> Void) {
        let userURL = baseURL.appendingPathComponent("signup/")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: String] = ["firstname": firstName,
                                      "lastname": lastName,
                                      "phone": phone,
                                      "password": password]
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let _ = try? jsonDecoder.decode(User.self, from: data) {
                self.loginUser(phone: phone, password: password, completion: { (_) in
                    completion(true)
                })
            } else {
                completion(false)
            }
        }
        task.resume()
    }

    func loginUser(phone: String, password: String, completion: @escaping (Bool) -> Void) {
        let userURL = baseURL.appendingPathComponent("login/")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: String] = ["phone": phone,
                                      "password": password]
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
                if let data = data, let token = try? jsonDecoder.decode(Token.self, from: data) {
                    print("login: OK")
                    self.token = token.token
                    self.saveToken()
                    self.getUser { (_) in
                        completion(true)
                    }
                } else {
                    print("login: FAILED")
                    completion(false)
            }
        }
        task.resume()
    }
    
    
    func getUser(completion: @escaping (Bool) -> Void) {
        let orderURL = baseURL.appendingPathComponent("sec/user/")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue(self.token ?? "", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
                if let data = data, let user = try? jsonDecoder.decode(User.self, from: data) {
                    print("user: OK")
                    self.getMeetings { (meetings) in
                        self.uploadCalendar { (_) in }
                        self.user = User(id: user.id, firstName: user.firstName, lastName: user.lastName, phone: user.phone, meetings: meetings ?? [])
                        completion(true)
                    }
                } else {
                    print("user: FAILED")
                    completion(false)
                }
        }
        task.resume()
    }
    
    private func getMeetings(completion: @escaping ([Meeting]?) -> Void) {
        let userURL = baseURL.appendingPathComponent("sec/meeting/")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "GET"
        request.setValue(self.token ?? "", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            if let data = data, let meetings = try? jsonDecoder.decode([Meeting].self, from: data) {
                print("meetings: OK")
                completion(meetings)
            } else {
                print("meetings: FAILED")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func uploadCalendar(completion: @escaping (Bool) -> Void) {
        let userURL = baseURL.appendingPathComponent("sec/user/calendar/")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.token ?? "", forHTTPHeaderField: "Authorization")
        
        let data: CalendarModel = self.loadEvents()
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("uploadCalendar: OK")
                    completion(true)
                } else {
                    print("uploadCalendar: FAILED")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    func getFree(duration: Int, users: [String], completion: @escaping ([StartEnd]?) -> Void) {
        let userURL = baseURL.appendingPathComponent("sec/user/free/")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.token ?? "", forHTTPHeaderField: "Authorization")
        
        let data = FreeMeeting(duration: duration, users: users)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            if let data = data, let calendar = try? jsonDecoder.decode([StartEnd]?.self, from: data) {
                print("free: OK")
                completion(calendar)
            } else {
                print("free: FAILED")
                completion([])
            }
        }
        task.resume()
    }
    
    func createMeeting(name: String, start: Date, end: Date, users: [String], completion: @escaping (Meeting?) -> Void) {
        let userURL = baseURL.appendingPathComponent("sec/meeting/")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.token ?? "", forHTTPHeaderField: "Authorization")
        
        let data = CreateMeeting(name: name, date: StartEnd(start: start, end: end), users: users.map({ (user) in
            return UserUser(user: user)
        }))
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            if let data = data, let meeting = try? jsonDecoder.decode(Meeting.self, from: data) {
                print("create: OK")
                self.getMeetings { (meetings) in
                    self.user?.meetings = meetings
                    completion(meeting)
                }
            } else {
                print("create: FAILED")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func deleteMeeting(meeting: String, completion: @escaping () -> Void) {
        let userURL = baseURL.appendingPathComponent("sec/meeting/\(meeting)")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "DELETE"
        request.setValue(self.token ?? "", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("delete: OK")
                    self.getMeetings { (meetings) in
                        self.user?.meetings = meetings ?? []
                        completion()
                    }
                } else {
                    print("delete: FAILED")
                    completion()
                }
            }
        }
        task.resume()
    }
    
    func responseMeeting(id: String, status: Int, completion: @escaping (Bool) -> Void) {
        let userURL = baseURL.appendingPathComponent("sec/meeting/\(id)/")
        
        var request = URLRequest(url: userURL)
        request.httpMethod = "PUT"
        request.setValue(self.token ?? "", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = ResponseMeeting(status: status)
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("response OK")
                    self.getMeetings { (meetings) in
                        self.user?.meetings = meetings ?? []
                        completion(true)
                    }
                } else {
                    print("response FAILED")
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    func logoutUser() {
        user = nil
        self.token = nil
        saveToken()
    }
    
    func loadEvents() -> CalendarModel {
        var events: [EKEvent] = []
        
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
    
        // Create start and end date NSDate instances to build a predicate for which events to select
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
    
        if let endDate = endDate {
            let eventStore = EKEventStore()
            // Use an event store instance to create and properly configure an NSPredicate
            let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            // Use the configured NSPredicate to find and return events in the store that match
            events.append(contentsOf: eventStore.events(matching: eventsPredicate))
            return CalendarModel(calendar: events.map({ (e) in
                return StartEnd(start: e.startDate, end: e.endDate)
            }))
        }
        return CalendarModel(calendar: [])
    }
    
    func saveToken() {
        let dokumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tokenFileUrl = dokumentsDirectory.appendingPathComponent("meet-me").appendingPathExtension("json")
        if let data = try? JSONEncoder().encode(self.token) {
            try? data.write(to: tokenFileUrl)
        }
    }
    
    func loadToken() {
        let dokumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let tokenFileUrl = dokumentsDirectory.appendingPathComponent("meet-me").appendingPathExtension("json")
        guard let data = try? Data(contentsOf: tokenFileUrl) else { return }
        self.token = (try? JSONDecoder().decode(String.self, from: data)) ?? ""
    }
}
