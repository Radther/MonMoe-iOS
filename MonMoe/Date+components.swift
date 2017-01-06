//
//  Date+components.swift
//  MonMoe
//
//  Created by Tom Sinlgeton on 06/01/2017.
//  Copyright © 2017 Tom Sinlgeton. All rights reserved.
//

import Foundation

extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
}
