//
//        .........     .........
//      ......  ...........  .....
//      ...        .....       ....
//     ...         ....         ...
//     ...       ........        ...
//     ....      .... ....      ...
//      ...      .... ....      ...
//      .....     .......     ....
//        ...      .....     ....
//         ....             ....
//           ....         ....
//            .....     .....
//              .....  ....
//                .......
//                  ...

import Foundation


enum DateHelper {
    static fileprivate let formatter = DateFormatter()
    static fileprivate let isoFormatter = ISO8601DateFormatter()
    static fileprivate let componentsFormatter = DateComponentsFormatter()
    static fileprivate let mediumStyleDateFormat = "MMM d"
    static fileprivate let eventListStyleDateFormat = "MMM d '@' h:mma"
    static fileprivate let eventDetailStyleDateFormat = "EEEE, MMMM d"
    static fileprivate let weekDayMonthDateFormat = "E, MMM d"
    static fileprivate let birthdayFormat = "d MMMM yyyy"
}

enum WeekDay: Int {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var localizedString: String {
        switch self {
        case .sunday: return NSLocalizedString("sunday", comment: "")
        case .monday: return NSLocalizedString("monday", comment: "")
        case .tuesday: return NSLocalizedString("tuesday", comment: "")
        case .wednesday: return NSLocalizedString("wednesday", comment: "")
        case .thursday: return NSLocalizedString("thursday", comment: "")
        case .friday: return NSLocalizedString("friday", comment: "")
        case .saturday: return NSLocalizedString("saturday", comment: "")
        }
    }
    
    var abbreviation: String {
        switch self {
        case .sunday: return NSLocalizedString("Su", comment: "First letter of the first day of the week (Sunday)")
        case .monday: return NSLocalizedString("M", comment: "First letter of the second day of the week (Monday)")
        case .tuesday: return NSLocalizedString("Tu", comment: "First letter of the third day of the week (Tuesday)")
        case .wednesday: return NSLocalizedString("W", comment: "First letter of the fourth day of the week (Wednesday)")
        case .thursday: return NSLocalizedString("Th", comment: "First two letters of the fifth day of the week (Thursday)")
        case .friday: return NSLocalizedString("F", comment: "First letter of the sixth day of the week (Friday)")
        case .saturday: return NSLocalizedString("Sa", comment: "First letter of the seventh day of the week (Saturday)")
        }
    }
    
}

extension String {
    
    var date: Date? {
        return DateHelper.isoFormatter.date(from: self)
    }
    
}


extension Date {
    
    static func daysUntil(_ date: Date) -> Int {
        let calendar: Calendar = Calendar.current
        
        let startDay = calendar.startOfDay(for: Date())
        let endDay = calendar.startOfDay(for: date)
        
        let components = (calendar as NSCalendar).components(.day, from: startDay, to: endDay, options: [])
        return components.day!
    }
    
    /// Format: "April 1, 2016"
    var longStyleDateString: String {
        DateHelper.formatter.dateStyle = .long
        return DateHelper.formatter.string(from: self)
    }
    
    /// Format: "9:15 AM"
    var shortStyleTimeString: String {
        DateHelper.formatter.dateStyle = .none
        DateHelper.formatter.timeStyle = .short
        return DateHelper.formatter.string(from: self)
    }
    
    /// Format: "Apr 1"
    var mediumStyleDateString: String {
        DateHelper.formatter.dateFormat = DateHelper.mediumStyleDateFormat
        return DateHelper.formatter.string(from: self)
    }
    
    /// Format: "2016-04-01T09:15:40Z"
    var iso8601String: String {
        return DateHelper.isoFormatter.string(from: self)
    }
    
    /// Format: "April 1 @ 9:15am"
    var monthDateAtTimeString: String {
        DateHelper.formatter.dateFormat = DateHelper.eventListStyleDateFormat
        return DateHelper.formatter.string(from: self)
    }
    
    /// Format: "Monday, April 1"
    var weekDayMonthDateString: String {
        DateHelper.formatter.dateFormat = DateHelper.eventDetailStyleDateFormat
        return DateHelper.formatter.string(from: self)
    }
    
    /// Format: "Mon, Apr 1"
    var mediumStyleWeekDayMonthDateString: String {
        DateHelper.formatter.dateFormat = DateHelper.weekDayMonthDateFormat
        return DateHelper.formatter.string(from: self)
    }
    
    /// Format: "1 April 1980"
    var birthdayString: String {
        DateHelper.formatter.dateFormat = DateHelper.birthdayFormat
        return DateHelper.formatter.string(from: self)
    }
    
    
    /// A string of a standard greeting based on the current time (ex. midnight-noon: "*Morning*", noon-5pm: "*Afternoon*", 5pm-midnight: "*Evening*"
    var greetingString: String {
        let hour = (Calendar.current as NSCalendar).component(.hour, from: self)
        var greeting = NSLocalizedString("Day", comment: "Day")
        
        switch hour {
        case 0..<12 :
            greeting = NSLocalizedString("Morning", comment: "Morning")
        case 12..<17 :
            greeting = NSLocalizedString("Afternoon", comment: "Afternoon")
        case 17...24 :
            greeting = NSLocalizedString("Evening", comment: "Evening")
        default:
            break
        }
        
        return greeting
    }
    
    /// - returns: String - lowercase string of the weekday ex. "tuesday"
    var dayOfWeek: String {
        let weekDayComponent = (Calendar.current as NSCalendar).components([.weekday], from: self)
        guard let weekDay = WeekDay(rawValue: weekDayComponent.weekday!) else { fatalError("weekday component outside of 7 day week?!") }
        return weekDay.localizedString
    }
    
    var dayAbbreviation: String {
        let weekDayComponent = (Calendar.current as NSCalendar).components([.weekday], from: self)
        guard let weekDay = WeekDay(rawValue: weekDayComponent.weekday!) else { fatalError("weekday component outside of 7 day week?!") }
        return weekDay.abbreviation
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDay, options: NSCalendar.Options())
    }
    
    fileprivate var isInTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    fileprivate var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func isBefore(_ date: Date) -> Bool {
        return self < date
    }
    
    func isAfter(_ date: Date) -> Bool {
        return self > date
    }
    
    /// Rounds sender to the nearest half hour ex. 10:12 -> 10:30
    var nearestHalfHour: Date {
        let currentMinutes = (Calendar.current as NSCalendar).component(.minute, from: self)
        
        var newComponents = DateComponents()
        let minutesToSubtractFrom = currentMinutes > 30 ? 60 : 30
        newComponents.minute = minutesToSubtractFrom - currentMinutes
        
        return (Calendar.current as NSCalendar).date(byAdding: newComponents, to: self, options: .matchFirst)!
    }
    
    /// Adds minutes to date
    func addMinutes(_ minutes: Int) -> Date {
        return (Calendar.current as NSCalendar).date(byAdding: .minute, value: minutes, to: self, options: .matchFirst)!
    }
    
    /// Determines if the sender (Date) is contained in a day that is *daysAgo* days before the current day
    /// Returns 'true' if sender is in the day, otherwise, 'false'
    /// - parameter daysAgo (Int) a positive integer of the days before the current day in which to check against (1 would check if date is in yesterday)
    /// - returns: Bool if the sender is contained in a day that is *daysAgo* in the past.
    func isDateIn(daysAgo days: Int) -> Bool {
        guard let date = (Calendar.current as NSCalendar).date(byAdding: .day, value: -days, to: Date(), options: .matchFirst) else { return false }
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func numberOfDaysSince(_ startDate: Date) -> Int {
        let calendar: Calendar = Calendar.current
        
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: self)
        
        let components = (calendar as NSCalendar).components(.day, from: startDay, to: endDay, options: [])
        return components.day!
    }
    
    /// - Tomorrow: "tomorrow"
    /// - Date(): "today" (monday ex.),
    /// - Yesterday: "yesterday"
    /// - DayBeforeYesterday: "saturday"
    /// - DayBeforeThat: "friday"
    /// - All dates before and after that: "Mar 17"
    /// - returns: a string of the sender in a format similar to the photos app (an Date in the current day would return "today")
    var proximityDateString: String {
        if self.isInTomorrow {
            return NSLocalizedString("tomorrow", comment: "")
        } else if self.isInToday {
            return NSLocalizedString("today", comment: "")
        } else if self.isInYesterday {
            return NSLocalizedString("yesterday", comment: "")
        } else if self.isDateIn(daysAgo: 2) || self.isDateIn(daysAgo: 3) {
            return self.dayOfWeek
        } else {
            return self.mediumStyleDateString
        }
    }

    /// for dates within the last 6 days it returns the proximity string ("today", "yesterday" etc.) with the time appended. Ex. "today at 2:34pm"
    var proximityDateTimeString: String {
        if numberOfDaysSince(self) < 7 {
            let format = NSLocalizedString("%@ at %@", comment: "ex. yesterday at 1:30pm")
            return String.localizedStringWithFormat(format, proximityDateString, shortStyleTimeString)
        } else {
            return proximityDateString
        }
    }
    
    func addWeeks(_ numberOfWeeks: Int) -> Date {
        var components = DateComponents()
        components.day = 7 * numberOfWeeks
        guard let newDate = (Calendar.current as NSCalendar).date(byAdding: components, to: self, options: []) else { fatalError("tried adding \(numberOfWeeks) weeks to \(self)") }
        return newDate
    }
    
    func addDays(_ numberOfDays: Int) -> Date {
        var components = DateComponents()
        components.day = numberOfDays
        guard let newDate = (Calendar.current as NSCalendar).date(byAdding: components, to: self, options: []) else { fatalError("tried adding \(numberOfDays) days to \(self)") }
        return newDate
    }
    
}
