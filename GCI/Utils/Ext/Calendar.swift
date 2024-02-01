//
//  Calendar.swift
//  neopixl_ext
//
//  Created by Joris Thiery on 22/02/2018.
//  Copyright © 2018 Joris Thiery. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class CalendarHelper: NSObject {
    typealias SuccessHelper = (_ succes: Bool) -> Void
    typealias SuccessAddHelper = (_ eventIdentifier: String?) -> Void
    
    static let shared: CalendarHelper = {
        return CalendarHelper()
    }()
    
    let eventStore: EKEventStore = EKEventStore()
    
    func delete(event eventIdentifier: String, withCompletionHandler completionHandler: @escaping SuccessHelper) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            guard !granted || error == nil else {
                completionHandler(false)
                return
            }
            
            if let event = self.eventStore.event(withIdentifier: eventIdentifier) {
                do {
                    try self.eventStore.remove(event, span: .thisEvent)
                    completionHandler(true)
                    return
                } catch let error as NSError {
                    print("error while saving event : \(error )")
                    completionHandler(false)
                }
            } else {
                completionHandler(false)
            }
        }
    }
    
    func add(forTitle title: String, andNotes note: String, forLocation location: String, atDate date: Date, withMinuteDurante minuteDuration: Int, completionHandler: @escaping SuccessAddHelper) {
        self.eventStore.requestAccess(to: .event) { (granted, error) in
            guard !granted || error == nil else {
                completionHandler(nil)
                return
            }
            
            let calendar = self.eventStore.defaultCalendarForNewEvents
            let myEvent = EKEvent(eventStore: self.eventStore)
            myEvent.title = title
            myEvent.notes = note
            myEvent.startDate = date
            myEvent.location = location
            let durationSeconds = Double(minuteDuration * 60)
            myEvent.endDate = date.addingTimeInterval(durationSeconds)
            myEvent.calendar = calendar
            do {
                try self.eventStore.save(myEvent, span: .thisEvent)
                let eventIdentifier = myEvent.eventIdentifier
                completionHandler(eventIdentifier)
                return
            } catch let error as NSError {
                print("error while saving event : \(error )")
                completionHandler(nil)
            }
        }
    }
}
