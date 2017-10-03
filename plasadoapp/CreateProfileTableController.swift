//
//  CreateProfileTableController.swift
//  plasado
//
//  Created by Emperor on 8/5/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
import DatePickerDialog
import Alamofire
import SVProgressHUD
import Firebase
class CreateProfileTableController: UITableViewController {

    @IBOutlet weak var holiday_dates: AHTagsLabel!
    
    @IBOutlet weak var hobbies_interests: AHTagsLabel!
    
    @IBOutlet weak var celebrations_events: AHTagsLabel!
    
    @IBOutlet weak var daysoffweek: AHTagsLabel!
    
    @IBOutlet weak var keywords: AHTagsLabel!
    
    @IBOutlet weak var dateofbirth: UITextField!
    
    @IBOutlet weak var gender: UITextField!
    
    @IBOutlet weak var comments: UITextField!
    
    
    
    @IBOutlet weak var view_upcomingHoliday: UIView!
    
    @IBOutlet weak var view_hobbiesInterests: UIView!
    
    @IBOutlet weak var view_celebrationsEvents: UIView!
    
    @IBOutlet weak var view_daysoffWork: UIView!
    
    @IBOutlet weak var view_Keywords: UIView!
    
    @IBOutlet weak var view_dateofbirth: UIView!
    
    @IBOutlet weak var view_gender: UIView!
    
    @IBOutlet weak var view_Comments: UIView!
    
    
    @IBOutlet weak var appID: UILabel!
    
    @IBAction func saveProfile(_ sender: Any) {
        LocalStorge.user.comments = self.comments.text!
        LocalStorge.user.daysoffweek = []
        for tag in self.daysoffweek.tags!{
            if tag.enabled == false{
                LocalStorge.user.daysoffweek.append(tag.title)
                
            }
        }
        Database.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: LocalStorge.user.email).observeSingleEvent(of: DataEventType.value, with: { (snap) in
            let rootRef = Database.database().reference()
            if snap.exists() == true{
                rootRef.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(LocalStorge.user.toJSON())
                self.performSegue(withIdentifier: "signup", sender: nil)
            }
        })

        
    }
    
    @IBAction func onUpcomingHoliday(_ sender: Any) {
        let upcomingController = UIAlertController(title: "Upcoming Holiday", message: "", preferredStyle: UIAlertControllerStyle.alert)
        upcomingController.addTextField { (textField) in
            textField.placeholder = "Upcoming Holiday"
        }
        upcomingController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            

            let newUpcoming : String = (upcomingController.textFields?[0].text)!
            if (newUpcoming.isEmpty || newUpcoming == nil){
                
            } else {

                let newTag = AHTag(dictionary: ["URL" : "url", "TITLE" : newUpcoming,"COLOR":"0xFF8F8F","ENABLED" : false, "CATEGORY" : "category"])
            
                /*var tagArray : [AHTag] = self.upcoming_Holiday.tags!
                tagArray.append(newTag)
                se lf.upcoming_Holiday.setTags(tagArray)
                self.tableView.reloadData()*/
                
            }
            
        }))
        
        self.present(upcomingController, animated: true, completion: nil)
    }
    
    @IBAction func onAddHobbies(_ sender: Any) {
        let hobbiesController = UIAlertController(title: "Hobbies and Interests", message: "", preferredStyle: UIAlertControllerStyle.alert)
        hobbiesController.addTextField { (textField) in
            textField.placeholder = "Hobbies and Interests"
        }
        hobbiesController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            let newHobbies : String = (hobbiesController.textFields?[0].text)!
            if (newHobbies.isEmpty || newHobbies == nil){
            } else {

                var newTag = AHTag(dictionary: ["URL" : "url", "TITLE" : newHobbies,"COLOR":"0xFF8F8F","ENABLED" : true, "CATEGORY" : "category"])
            
                var tagArray : [AHTag] = self.hobbies_interests.tags!
                newTag.enabled = false
                tagArray.append(newTag)
                self.hobbies_interests.setTags(tagArray)
                self.tableView.reloadData()
            }
            
        }))
        
        self.present(hobbiesController, animated: true, completion: nil)
    }

    @IBAction func onKeywords(_ sender: Any) {
        let keywordController = UIAlertController(title: "Keywords", message: "", preferredStyle: UIAlertControllerStyle.alert)
        keywordController.addTextField { (textField) in
            textField.placeholder = "Keyword title"
        }
        keywordController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            let keyword : String = (keywordController.textFields?[0].text)!
            if (keyword == nil || keyword.isEmpty){
                
            } else{
                var newTag = AHTag(dictionary: ["URL" : "url", "TITLE" : keyword,"COLOR":"0xFF8F8F","ENABLED" : true, "CATEGORY" : "category"])
            
                var tagArray : [AHTag] = self.keywords.tags!
                newTag.enabled = false
                tagArray.append(newTag)
                self.keywords.setTags(tagArray)
                self.tableView.reloadData()
            
            }
        }))
        
        self.present(keywordController, animated: true, completion: nil)

    }
    
    
    @IBAction func onAddEvent(_ sender: Any) {
        self.eventController.textFields?[0].text = ""
        self.eventController.textFields?[1].text = ""
        present(self.eventController, animated: true, completion: nil)
    }
    var birthDate : Date!
    var EventDate : Date!
    let eventController = UIAlertController(title: "Event title and Date", message: "", preferredStyle: UIAlertControllerStyle.alert)
    func shadow(vwBack : UIView) {
        vwBack.layer.masksToBounds = false
        vwBack.layer.shadowColor = UIColor.black.cgColor
        vwBack.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        vwBack.layer.shadowOpacity = 0.7
        vwBack.layer.shadowRadius = 1.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventController.addTextField { (textField) in
            textField.placeholder = "title"
        }
        eventController.addTextField { (textField) in
            textField.placeholder = "Date"
            textField.delegate = self
        }
        eventController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if ((self.eventController.textFields?[0].text?.isEmpty)! || (self.eventController.textFields?[1].text?.isEmpty)! ){
                
            }
            else{
                var tag = AHTag(dictionary: ["URL" : "url", "TITLE" : (self.eventController.textFields?[0].text)!+"-" + (self.eventController.textFields?[1].text!)!,"COLOR":"0xFF8F8F","ENABLED" : true, "CATEGORY" : "category"])
                tag.enabled = false
                var tagArray : [AHTag] = self.celebrations_events.tags!
                tagArray.append(tag)
            
                self.celebrations_events.setTags(tagArray)
            
                self.tableView.reloadData()
            }
        }))
        
        eventController.textFields?[1].delegate = self
        


        
        shadow(vwBack : view_upcomingHoliday)
        shadow(vwBack : view_hobbiesInterests)
        shadow(vwBack : view_celebrationsEvents)
        shadow(vwBack : view_daysoffWork)
        shadow(vwBack : view_Keywords)
        shadow(vwBack : view_dateofbirth)
        shadow(vwBack : view_gender)
        shadow(vwBack : view_Comments)
        
        dateofbirth.delegate = self
        gender.delegate = self
        //actionController.view.subviews.first?.backgroundColor = UIColor.darkGray

        var tagArray : [AHTag] = []
        /*for event in (LocalStorge.user.events){
            let date = event.start_time.dateFromISO8601
            var formater = DateFormatter()
            formater.dateFormat = "MM/dd/yyyy"
            
            let tag = AHTag(dictionary: ["URL" : "url", "TITLE" : formater.string(from: date!) + "-" + event.name,"COLOR":"0xFF8F8F","ENABLED" : false, "CATEGORY" : "category"])
            tagArray.append(tag)
        }*/
        for event in LocalStorge.ical_Events{
            let tag = AHTag(dictionary: ["URL" : "url", "TITLE" : (event.start_time.dateFromISO8601?.shortiso8601)! + "-" + event.name,"COLOR":"0xFF8F8F","ENABLED" : false, "CATEGORY" : "category"])
            tagArray.append(tag)
            print(event.toJSON())
        }
        self.celebrations_events.setTags(tagArray)
        self.celebrations_events.isUserInteractionEnabled = false
        
        
//        tagArray = []
//        for holiday in (LocalStorge.user.holidaydates){
//
//            let tag = AHTag(dictionary: ["URL" : "url", "TITLE" : holiday.date + "-" + holiday.name,"COLOR":"0xFF8F8F","ENABLED" : false, "CATEGORY" : "category"])
//            tagArray.append(tag)
//        }
//        self.holiday_dates.setTags(tagArray)
//        self.holiday_dates.isUserInteractionEnabled = false
        
        tagArray = []
        let daySymbols : [String] = ["Mon","Tue", "Wed","Thr","Fri","Sat","Sun"]
        for symbol in daySymbols{
            var tag = AHTag(dictionary: ["URL" : "url", "TITLE" : symbol,"COLOR":"0xFF8F8F","ENABLED" : false, "CATEGORY" : "category"])
            if LocalStorge.user.daysoffweek.contains(symbol){
                tag.enabled = false
            } else{
                tag.enabled = true
            }
            tagArray.append(tag)
        }
        self.daysoffweek.setTags(tagArray)
        self.daysoffweek.isUserInteractionEnabled = true
        
        self.dateofbirth.text = LocalStorge.user.birthday
        
        self.gender.text = LocalStorge.user.gender
        
        self.comments.text = LocalStorge.user.comments
        
        self.appID.text = LocalStorge.appID
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= 2{
            return 70
        }
        else{
            if indexPath.row == 0 {return 115}
            if indexPath.row == 1 {return 15}
        }
        return 70
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= 2{
            return UITableViewAutomaticDimension
        }
        else{
            if indexPath.row == 0 {return 115}
            if indexPath.row == 1 {return 15}
        }
        return UITableViewAutomaticDimension
    }
    func showBirthdaypickerDlg() {
        let minDate = Calendar.current.date(byAdding: Calendar.Component.year, value: 20, to: Date())
        let maxDate = Calendar.current.date(byAdding: Calendar.Component.year, value: -30, to: Date())
        DatePickerDialog().show("Birth Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), minimumDate: minDate, maximumDate: maxDate, datePickerMode: UIDatePickerMode.date) { (date) in
            
            let dateFormater = DateFormatter()
            
            if date != nil{
                self.birthDate = date
                dateFormater.dateFormat = "MM/dd/yyyy"
                self.dateofbirth.text = dateFormater.string(from: date!)
            }
            
        }
        
        
    }
    func showEventdaypickerDlg() {
        let minDate = Calendar.current.date(byAdding: Calendar.Component.year, value: 20, to: Date())
        let maxDate = Calendar.current.date(byAdding: Calendar.Component.year, value: -30, to: Date())
        DatePickerDialog().show("Event Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), minimumDate: minDate, maximumDate: maxDate, datePickerMode: UIDatePickerMode.date) { (date) in
            
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "MM/dd/yyyy"
            if date != nil{
                self.eventController.textFields?[1].text = dateFormater.string(from: date!)
            }
            
        }
        
        
    }

}
extension CreateProfileTableController : UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        scoreText.endEditing(true)
        return true
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == self.dateofbirth || textField == self.eventController.textFields?[1]){
            if (textField == self.dateofbirth){
                dateofbirth.resignFirstResponder()
                showBirthdaypickerDlg()
            }
            if (textField == self.eventController.textFields?[1]){
                self.eventController.textFields?[1].resignFirstResponder()
                showEventdaypickerDlg()
            }
            return false;
        }
        if (textField == self.gender){
            
            gender.resignFirstResponder()
            let actionController = UIAlertController(title: "Select Gender", message: "Please select male or female", preferredStyle: UIAlertControllerStyle.actionSheet)
            actionController.view.subviews.first?.backgroundColor = UIColor.darkGray
            actionController.addAction(UIAlertAction(title: "Male", style: UIAlertActionStyle.default, handler: { (action) in
                self.gender.text = "Male"
            }))
            
            actionController.addAction(UIAlertAction(title: "Female", style: UIAlertActionStyle.default, handler: { (action) in
                self.gender.text = "Female"
            }))
            self.present(actionController, animated: true, completion: nil)
            return false;
        }
        
        return true;
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
            
            
        }
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tableView.setContentOffset(CGPoint(x: 0, y : 200), animated: true)
    }
}
extension CreateProfileTableController : UIActionSheetDelegate{
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        
    }
    
}

