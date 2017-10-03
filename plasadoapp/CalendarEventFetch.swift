//
//  CalendarEventFetch.swift
//  plasadoapp
//
//  Created by Emperor on 9/29/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import Foundation
import EventKit
class CalendarEventFetch{
    var calendars: [EKCalendar]?
    var ical_Events : [CelebrationEvent]! = []
    var start_date : Date!
    var end_date : Date!
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            self.loadCalendars()
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied: break
        // We need to help them give us permission
        
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(openSettingsUrl!)
        }
    }
    func requestAccessToCalendar() {
        
        EKEventStore().requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadCalendars()
                })
            } else {
                DispatchQueue.main.async(execute: {
                    let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.shared.openURL(openSettingsUrl!)
                })
            }
        })
    }
    
    func loadCalendars() {
        self.calendars = EKEventStore().calendars(for: EKEntityType.event).sorted() { (cal1, cal2) -> Bool in
            return cal1.title < cal2.title
        }
        self.ical_Events = []
        self.calendars?.forEach({ (calendar) in
            print(calendar.title)
            let events = self.loadEvents(calendar: calendar)
            events.forEach({ (event) in
                let celebrationEvent = CelebrationEvent(value: [
                    "name" : event.title,
                    "description" : (event.dictionaryWithValues(forKeys: ["title"])["title"]) as! String,
                    "end_time" : event.endDate.iso8601,
                    "start_time" : event.startDate.iso8601
                    ])
                self.ical_Events.append(celebrationEvent)
            })
            
        })
    }
    func loadEvents(calendar : EKCalendar) -> [EKEvent]{
        let eventStore = EKEventStore()
        let eventsPredicate = eventStore.predicateForEvents(withStart: self.start_date, end: self.end_date, calendars: [calendar])
        let events = eventStore.events(matching: eventsPredicate).sorted(){
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
        return events
    }
}
