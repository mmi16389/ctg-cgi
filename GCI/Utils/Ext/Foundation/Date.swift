//
//  Date.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 22/02/2018.
//  Copyright © 2018 Joris Thiery. All rights reserved.
//

import UIKit

extension Date {
    
    /// Check if date is in future.
    public var isInFuture: Bool {
        return self > Date()
    }
    
    /// Check if date is in past.
    public var isInPast: Bool {
        return self < Date()
    }
    
    /// Set Time to Date
    func setTime(hours: Int, minutes: Int, seconds: Int) -> Date {
        let gregorian = Calendar(identifier: .gregorian)
        
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        
        return gregorian.date(from: components)!
    }
    
    /// Check if date is within today.
    public var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is within yesterday.
    public var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Check if date is within tomorrow.
    public var isInTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    /// Check if date is within a weekend period.
    public var isInWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    
    /// Check if date is within a weekday period.
    public var isWorkday: Bool {
        return !Calendar.current.isDateInWeekend(self)
    }
    
    /// Check if date is within the current week.
    public var isInCurrentWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Check if date is within the current month.
    public var isInCurrentMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Check if date is within the current year.
    public var isInCurrentYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    /// Date by adding multiples of calendar component.
    public func adding(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    
    /// check if a date is between two other dates
    public func isBetween(_ startDate: Date, _ endDate: Date, includeBounds: Bool = false) -> Bool {
        if includeBounds {
            return startDate.compare(self).rawValue * compare(endDate).rawValue >= 0
        }
        return startDate.compare(self).rawValue * compare(endDate).rawValue > 0
    }
    
    /// Get Day of week 
    func dayOfWeek() -> Int {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: self)
        return weekDay
    }
    
    func toDateString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.languageCode ?? "fr_FR")
        dateFormatter.dateStyle = style
        
        return dateFormatter.string(from: self)
    }
    
    func toTimeString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.languageCode ?? "fr_FR")
        dateFormatter.timeStyle = style
        
        return dateFormatter.string(from: self)
    }
}
