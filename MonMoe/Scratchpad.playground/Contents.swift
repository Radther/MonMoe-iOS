//: Playground - noun: a place where people can play

import UIKit

let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

let date = formatter.date(from: "2017-02-07T14:30:00.000Z")!
let secondDate = formatter.date(from: "2017-02-07T14:30:00.000Z")!
print(date)

let calendar = Calendar.current

let year: Int = calendar.component(.year, from: date)
let month = calendar.component(.month, from: date)
let day = calendar.component(.day, from: date)

print(year)
print(month)
print(day)

