//
//  String.swift
//  Meet ME
//
//  Created by Vlada on 16.02.2021.
//

import Foundation

extension String {
    func isValidPhoneNumber() -> Bool {
        let regEx = "[0-9]{9}$"

        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: self)
    }
}
