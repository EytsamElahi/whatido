//
//  StringExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import Foundation

extension String {

    //    / Converts string date to `subject` date.
    //    /
    //    / ```
    //    / print(date.toDateFormat1()) // "20-08-2023"
    //    / ```
    //    /
    //    / - Parameters:
    //    /     - subject: Date string.
    //    /
    //    / - Returns: Converted to Date format `dd-MM-yyyy`.
    func toDateFormat() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
       return dateFormatter.date(from: self)
    }

//    func toTimeFormat() -> String {
//        debugPrint("Before Date \(self)")
//        if let is12HourFormat = Helper.is12HourFormat() {
//            if is12HourFormat {
//                let dateFormatter = DateFormatter()
//
//                // step 1
//                dateFormatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss a zzz" // input format
//                if let date = dateFormatter.date(from: self) {
//                    // step 2
//                    dateFormatter.dateFormat = "HH:mm" // output format
//                    let string = dateFormatter.string(from: date)
//                    return string
//                } else {
//                    return ""
//                }
//            } else {
//
//                var cleanedDateString = self
//
//                cleanedDateString = cleanedDateString.replacingOccurrences(of: "AM", with: "")
//                cleanedDateString = cleanedDateString.replacingOccurrences(of: "PM", with: "")
//                cleanedDateString = cleanedDateString.replacingOccurrences(of: "μμ", with: "")
//                cleanedDateString = cleanedDateString.replacingOccurrences(of: "πμ", with: "")
//
//                // Remove any whitespace that may be left after replacing 'AM'/'PM'
//                cleanedDateString = cleanedDateString.trimmingCharacters(in: .whitespaces)
//
//                // Now, clean up the UTC offset (e.g., "UTC+05" to "+05")
//                cleanedDateString = cleanedDateString.replacingOccurrences(of: "UTC", with: "").trimmingCharacters(in: .whitespaces)
//
//                // Create a DateFormatter instance to parse the cleaned date string
//                let dateFormatter = DateFormatter()
//
//                // Define the input format that matches the structure of the cleaned date string
//                dateFormatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm:ss Z"  // Use 24-hour format (HH:mm:ss) and UTC offset (Z)
//
//                // Set the locale to ensure month and day are parsed correctly
//                dateFormatter.locale = .current//Locale(identifier: "el_GR")
//
//                // Attempt to parse the date string into a Date object
//                if let date = dateFormatter.date(from: cleanedDateString) {
//                    // Now that we have a Date object, we can extract the time portion
//                    let timeFormatter = DateFormatter()
//                    timeFormatter.dateFormat = "HH:mm" // 24-hour time format
//
//                    // Return the formatted time as a string
//                    return timeFormatter.string(from: date)
//                } else {
//                    // If the string couldn't be converted to a Date, return nil
//                    print("Failed to convert the date string.")
//                    return ""
//                }
//            }
//        }
//        return ""
//    }

    /// A function which returns string date in `dd-MM-yyyy` format.
    ///
    /// It takes date in string and changes it's format.
    ///
    func toDateFormat1() -> String? {
        let normalizedDateString = self.replacingOccurrences(of: "UTC+0428", with: "+04:28")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss a zzz"
        let date = dateFormatter.date(from: normalizedDateString)
        return date?.toDateReturnString2()
    }
    @discardableResult
    func toTimeStampInString() -> String? {
       return convert(dateString: self, fromDateFormat: "MM/dd/yy", toDateFormat: "MMMM dd, yyyy 'at' hh:mm:ss a zzz")
//       let date = convert(dateString: self, fromDateFormat: "MM/dd/yy", toDateFormat: "MMMM dd, yyyy 'at' hh:mm:ss a zzz")
//        let formater = DateFormatter()
//        formater.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss a zzz"
//        return formater.date(from: date ?? "")
    }

     func toTimeStamp() -> Date? {
        var cleanedDateString = self
        cleanedDateString = cleanedDateString.replacingOccurrences(of: "AM", with: "")
        cleanedDateString = cleanedDateString.replacingOccurrences(of: "PM", with: "")
         cleanedDateString = cleanedDateString.replacingOccurrences(of: "μμ", with: "")
         cleanedDateString = cleanedDateString.replacingOccurrences(of: "πμ", with: "")
        // Remove any whitespace that may be left after replacing 'AM'/'PM'
        cleanedDateString = cleanedDateString.trimmingCharacters(in: .whitespaces)

        // Now, clean up the UTC offset (e.g., "UTC+05" to "+05")
        cleanedDateString = cleanedDateString.replacingOccurrences(of: "UTC", with: "").trimmingCharacters(in: .whitespaces)

        // Create a DateFormatter instance to parse the cleaned date string
        let dateFormatter = DateFormatter()

        // Define the input format that matches the structure of the cleaned date string
        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' HH:mm:ss Z"  // Use 24-hour format (HH:mm:ss) and UTC offset (Z)

        // Set the locale to ensure month and day are parsed correctly
         dateFormatter.locale = .current//Locale(identifier: "en_US")

        print(cleanedDateString)
        // Attempt to parse the date string into a Date object
         return dateFormatter.date(from: cleanedDateString)
    }

    func toTimeStamp(format: String? = nil) -> Date? {
       let date = convert(dateString: self, fromDateFormat: format ?? "MM/dd/yy", toDateFormat: "MMMM dd, yyyy 'at' hh:mm:ss a zzz")
        let formater = DateFormatter()
        formater.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss a zzz"
        return formater.date(from: date ?? "")
    }

    func convert(dateString: String, fromDateFormat: String, toDateFormat: String) -> String? {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = fromDateFormat

        if let fromDateObject = fromDateFormatter.date(from: dateString) {

            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = toDateFormat

            let newDateString = toDateFormatter.string(from: fromDateObject)
            return newDateString
        }
        return nil
    }

    var trimmed: Self {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

//    func localize(comment: String = "") -> String {
//
//        let value = NSLocalizedString(self, comment: comment)
//        let defaultLanguage = AppData.locale?.rawValue ?? AppState.shared.locale.rawValue
//        guard let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj"), let bundle = Bundle(path: path) else {
//            return value
//        }
//
//        return NSLocalizedString(self, bundle: bundle, comment: "")
//    }
//    func forceLocalize(language: String) -> String {
//
//        let value = NSLocalizedString(self, comment: "")
//        let defaultLanguage = language
//        guard let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj"), let bundle = Bundle(path: path) else {
//            return value
//        }
//
//        return NSLocalizedString(self, bundle: bundle, comment: "")
//    }

    var hasUpperCase: Bool {
        return self.contains {$0.isUppercase}
    }

    var hasLowerCase: Bool {
        return self.contains {$0.isLowercase}
    }

    var hasNumbers: Bool {
        return self.contains {$0.isNumber}
    }

    var hasSpecialCharacter: Bool {
        let specialCharacterRegex = "[^a-zA-Z0-9]"
        return self.range(of: specialCharacterRegex, options: .regularExpression) != nil
    }
}
