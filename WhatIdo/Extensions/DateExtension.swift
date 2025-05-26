//
//  DateExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import Foundation

extension Date {
    var components: DateComponents {
        return Calendar.current.dateComponents([.day, .year, .month], from: self)
    }

    var isCurrentWeekDate: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        guard let weekDates = calendar.range(of: .weekday, in: .weekOfYear, for: today) else {return false}
        let dates = weekDates.compactMap {calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today)}
        return dates.contains(where: {$0.toDateReturnString2() == self.toDateReturnString2()})
    }

    var isLastWeekDate: Bool {
        let dateInWeek = Date()
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: dateInWeek)
        guard let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: dateInWeek.addingTimeInterval(60 * 60 * 24 * 7 * -1)) else {return false}
        let lastWeekDates = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: dateInWeek.addingTimeInterval(60 * 60 * 24 * 7 * -1)) }
        return lastWeekDates.contains(where: {$0.toDateReturnString2() == self.toDateReturnString2()})
    }

    func toTimeReturnsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

    func to12HourFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
    }

    func changeFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: self)
    }

    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: self)
    }

    func toFIRString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = firestoreDateFormat
        return dateFormatter.string(from: self)
    }

    func getDateForTransactionDetail() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMM yyyy"
        return dateFormatter.string(from: self)
    }

    func getMeasurementDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMMM, yyyy"
        return dateFormatter.string(from: self)
    }

    func toDateReturnString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: self)
    }

    func toDateReturnString3() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }

    func toDateReturnString2() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: self)
    }

    func toDay() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        let currentDate = calendar.startOfDay(for: Date())
        let forDate = calendar.startOfDay(for: self)
        if calendar.isDateInToday(forDate) {
            return self.toTimeReturnsString()
        } else if calendar.isDateInYesterday(forDate) {
            return "Yesterday"
        } else {
            return self.toDateReturnString()
        }
    }
    // MARK: - This func returns the previous date from current date depends on the number.
    func getPreviousDaysDate(_ numberOfDays: Int) -> Date {
        if numberOfDays > 0 { return Date()}
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: numberOfDays, to: self) ?? Date()
    }
    func getMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: self)
    }
    func getDayName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self)
    }
    func formatDateShort() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d" // E = short day of week, d = day number
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent output
        return formatter.string(from: self)
    }
    func getDayOnlyFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

    var milliSecSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliSec: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliSec / 1000))
    }

    static func - (recent: Date, previous: Date) -> Int {
        guard let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day else {return -1}
        return day
    }

    func beginTime() -> Date {
       guard let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self) else {return Date()}
        return date
    }

    func endTime() -> Date {
        guard let date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) else {return Date()}
        return date
    }

    func tomorrow() -> Date {
        guard let date = Calendar.current.date(byAdding: .day, value: 1, to: self) else {return Date()}
        return date
    }

    func addDay(day: Int) -> Date {
        guard let date = Calendar.current.date(byAdding: .day, value: day, to: self) else {return Date()}
        return date
    }

    func getFirstDateOfMonth() -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))
    }

    // MARK: -
    func makeDateToDayEnd() -> Self? {
//        let dateFormatter = DateFormatter()
//
//        // Set the input date format
//        dateFormatter.dateFormat = inputFormat
//
//        // Set the input time zone to UTC based on the input date string
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
//
//        // Parse the date object
//        guard let date = dateFormatter.date(from: dateString) else { return nil }
//
// Adjust time components if needed
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current // UTC

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
    //    if isFrom {
    //        dateComponents.hour = 0
    //        dateComponents.minute = 0
    //        dateComponents.second = 0
    //    } else if isTo {
//            dateComponents.hour = 23
//            dateComponents.minute = 59
//            dateComponents.second = 59
    //    }

        return calendar.date(from: dateComponents)
    }

}
extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        guard let date = Calendar.current.date(byAdding: components, to: self.startOfDay()) else {return Date()}
        return date
    }
}

func stromhDate(from input: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = firestoreDateFormat
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

    guard let date = dateFormatter.date(from: input) else {
        return nil
    }

    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = hour12TimeFormat
        return timeFormatter.string(from: date)
    }

    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "M/d/yyyy"

    return outputFormatter.string(from: date)
}

var firestoreDateFormat = "MMMM dd, yyyy 'at' h:mm:ss a 'UTC'X"
var genericDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
var measurmentDateFormat = "EEEE dd MMMM, yyyy"

// 12hour time
var hour12TimeFormat = "hh:mm a"
