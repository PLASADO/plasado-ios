//
//  CalendarViewController.swift
//  plasado
//
//  Created by a on 8/9/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
import SwipeCellKit
import FSCalendar
class CalendarViewController: UIViewController ,FSCalendarDataSource, FSCalendarDelegate,FSCalendarDelegateAppearance, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var calendar: FSCalendar!
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var switch_CalendarBtn: UIButton!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive : Bool = false
    
    //var data = ["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin","Seattle"]
    //var filtered:[String] = []
    
    var data : [CelebrationEvent] = []
    var filtered : [CelebrationEvent] = []
    var eventFetch : CalendarEventFetch! = CalendarEventFetch()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        self.calendar.locale = Locale.current
        self.calendar.select(Date())
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        self.calendar.accessibilityIdentifier = "calendar"
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.isNavigationBarHidden = true
        
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let startOfMonth = Calendar.current.date(from: comp)!
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)!
        eventFetch.start_date = startOfMonth
        eventFetch.end_date = endOfMonth
        eventFetch.checkCalendarAuthorizationStatus()
        
        self.data = getIntentionsinDay(date: self.calendar.selectedDate!)
        
        
    }
    func getIntentionsinDay(date : Date) -> [CelebrationEvent]{
        var eventArray : [CelebrationEvent] = []
        
        eventFetch.ical_Events.forEach { (event) in
            if event.start_time.dateFromISO8601?.shortiso8601 == event.end_time.dateFromISO8601?.shortiso8601{
                let orig_day = Calendar.current.component(Calendar.Component.day, from: event.start_time.dateFromISO8601!)
                let orig_month = Calendar.current.component(Calendar.Component.month, from: event.start_time.dateFromISO8601!)
                
                let current_day = Calendar.current.component(Calendar.Component.day, from: date)
                let current_month = Calendar.current.component(Calendar.Component.month, from: date)
                
                if ( orig_day == current_day && orig_month == current_month){
                    eventArray.append(event)
                }
            }
            else {
                if date.isBetweeen(date: event.start_time.dateFromISO8601!, andDate: event.end_time.dateFromISO8601!) == true{
                    eventArray.append(event)
                }
            }
        }
        
        LocalStorge.intentionArray.forEach{ (intention) in
            let current_day = Calendar.current.component(Calendar.Component.day, from: date)
            let current_month = Calendar.current.component(Calendar.Component.month, from: date)
            
            let orig_day = Calendar.current.component(Calendar.Component.day, from: intention.date.dateFromISO8601!)
            let orig_month = Calendar.current.component(Calendar.Component.month, from: intention.date.dateFromISO8601!)
            
            if ( orig_day == current_day && orig_month == current_month){
                //eventArray.append(event)
                var event = CelebrationEvent(value: [
                    "name" : intention.name,
                    "description" : intention.name,
                    "start_date" : intention.date,
                    "end_time" : intention.date
                ])
                eventArray.append(event)
            }
        }
        /*LocalStorge.contact_Birthdays.forEach { (event) in
            let start_time = event.start_time.dateFromISO8601
            let orig_day = Calendar.current.component(Calendar.Component.day, from: start_time!)
            let orig_month = Calendar.current.component(Calendar.Component.month, from: start_time!)
            
            let current_day = Calendar.current.component(Calendar.Component.day, from: date)
            let current_month = Calendar.current.component(Calendar.Component.month, from: date)
            
            if ( orig_day == current_day && orig_month == current_month){
                eventArray.append(event)
            }
        }*/
        return eventArray
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        self.searchBar.text = ""
        self.data = getIntentionsinDay(date: self.calendar.selectedDate!)
        self.filtered = []
        self.tableView.reloadData()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if calendar.scope == .month{
            var components = DateComponents()
            components.day = -8
            let start_Date = Calendar.current.date(byAdding: components, to: calendar.currentPage)
            components.day = 38
            let end_Date = Calendar.current.date(byAdding: components, to: calendar.currentPage)
            eventFetch.start_date = start_Date
            eventFetch.end_date = end_Date
            eventFetch.checkCalendarAuthorizationStatus()
        } else {
            var components = DateComponents()
            components.day = -2
            let start_Date = Calendar.current.date(byAdding: components, to: calendar.currentPage)
            components.day = 38
            let end_Date = Calendar.current.date(byAdding: components, to: calendar.currentPage)
            eventFetch.start_date = start_Date
            eventFetch.end_date = end_Date
            eventFetch.checkCalendarAuthorizationStatus()
        }
        
        calendar.reloadData()
    }
    


    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var num : Int = 0
 
        
        /*LocalStorge.contact_Birthdays.forEach { (event) in
            let start_time = event.start_time.dateFromISO8601
            let orig_day = Calendar.current.component(Calendar.Component.day, from: start_time!)
            let orig_month = Calendar.current.component(Calendar.Component.month, from: start_time!)
            
            let current_day = Calendar.current.component(Calendar.Component.day, from: date)
            let current_month = Calendar.current.component(Calendar.Component.month, from: date)
            
            if ( orig_day == current_day && orig_month == current_month){
                num = num + 1
            }
        }*/
        LocalStorge.intentionArray.forEach{ (intention) in
            let current_day = Calendar.current.component(Calendar.Component.day, from: date)
            let current_month = Calendar.current.component(Calendar.Component.month, from: date)
            
            let orig_day = Calendar.current.component(Calendar.Component.day, from: intention.date.dateFromISO8601!)
            let orig_month = Calendar.current.component(Calendar.Component.month, from: intention.date.dateFromISO8601!)
            
            if ( orig_day == current_day && orig_month == current_month){
                num = num + 1;
            }
        }
        eventFetch.ical_Events.forEach { (event) in
            let start_time = event.start_time.dateFromISO8601
            let end_time = event.end_time.dateFromISO8601
            
            
            if start_time?.shortiso8601 == end_time?.shortiso8601{
                let orig_day = Calendar.current.component(Calendar.Component.day, from: start_time!)
                let orig_month = Calendar.current.component(Calendar.Component.month, from: start_time!)
                
                let current_day = Calendar.current.component(Calendar.Component.day, from: date)
                let current_month = Calendar.current.component(Calendar.Component.month, from: date)
                
                if ( orig_day == current_day && orig_month == current_month){
                    num = num + 1
                }
            } else{
                if date.isBetweeen(date: start_time!, andDate: end_time!) == true{
                    num = num + 1
                } else {
                    
                }
            }
        }
        return num
    }
    

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        var colorArray : [UIColor] = []
        LocalStorge.intentionArray.forEach{ (intention) in
            let current_day = Calendar.current.component(Calendar.Component.day, from: date)
            let current_month = Calendar.current.component(Calendar.Component.month, from: date)
            
            let orig_day = Calendar.current.component(Calendar.Component.day, from: intention.date.dateFromISO8601!)
            let orig_month = Calendar.current.component(Calendar.Component.month, from: intention.date.dateFromISO8601!)
            
            if ( orig_day == current_day && orig_month == current_month){
                colorArray.append(UIColor.red)
            }
        }
        eventFetch.ical_Events.forEach { (event) in
            if event.start_time.dateFromISO8601?.shortiso8601 == event.end_time.dateFromISO8601?.shortiso8601{
                if event.start_time.dateFromISO8601?.shortiso8601 == date.shortiso8601{
                    colorArray.append(UIColor.red)
                }
            }
            else {
                let start_time = event.start_time.dateFromISO8601
                let end_time = event.end_time.dateFromISO8601
                if date.isBetweeen(date: start_time!, andDate: end_time!) == true{
                    colorArray.append(UIColor.red)
                }
                
            }
        }
        /*LocalStorge.contact_Birthdays.forEach { (event) in
            let start_time = event.start_time.dateFromISO8601
            let orig_day = Calendar.current.component(Calendar.Component.day, from: start_time!)
            let orig_month = Calendar.current.component(Calendar.Component.month, from: start_time!)
            
            let current_day = Calendar.current.component(Calendar.Component.day, from: date)
            let current_month = Calendar.current.component(Calendar.Component.month, from: date)
            
            if ( orig_day == current_day && orig_month == current_month){
                colorArray.append(UIColor.red)
            }

        }*/
        return colorArray
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onSwitchCalendar(_ sender: Any) {
        //self.performSegue(withIdentifier: "switchcalendar", sender: nil)
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        
    }
    func searchBarSearchButtonClsicked(_ searchBar: UISearchBar) {
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered.removeAll()
        filtered = data.filter({
            $0.name.localizedCaseInsensitiveContains(searchText)
        })
        if (searchText.characters.count == 0){
            searchActive = false
        }
        else{
            if(filtered.count == 0){
                searchActive = true;
            } else {
                searchActive = true;
            }
        }
        self.tableView.reloadData()
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return data.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell") as! CalendarTableViewCell
        cell.delegate = self
        if(searchActive){
            //cell.textLabel?.text = filtered[indexPath.row]
            cell.intention_Title.text = filtered[indexPath.row].name
            cell.intention_Content.text = filtered[indexPath.row].description
        } else {
            //cell.textLabel?.text = data[indexPath.row];
            cell.intention_Title.text = data[indexPath.row].name
            cell.intention_Content.text = data[indexPath.row].description
        }
        
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "myintention", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = ""
        navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = true
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 179/255, green: 33/255, blue: 33/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = false
        navigationController?.isNavigationBarHidden = true
    }
}

extension CalendarViewController : SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
        var deleteAction : SwipeAction!
        deleteAction = SwipeAction(style: .destructive, title: "") { (deleteAction, indexPath) in
            
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.8165897727, green: 0.1942726374, blue: 0.2604972124, alpha: 1)
        deleteAction.image = UIImage(named: "cancel")
        
        var moreAction : SwipeAction!
        moreAction = SwipeAction(style: .destructive, title: "") { (moreAction, indexPath) in
            self.performSegue(withIdentifier: "myintention", sender: nil)
        }
        moreAction.backgroundColor = #colorLiteral(red: 0.7607252002, green: 0.7608175874, blue: 0.7606938481, alpha: 1)
        moreAction.image = UIImage(named: "more")
        return [deleteAction,moreAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .border
        return options
    }
}
extension Date{
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2 as Date)
    }
}
