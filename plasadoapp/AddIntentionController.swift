//
//  AddIntentionController.swift
//  plasado
//
//  Created by a on 8/8/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
import DatePickerDialog
import CoreLocation
import GooglePlacePicker
import SVProgressHUD
import Alamofire
import RMPickerViewController
import SVProgressHUD
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Social
import SWMessages
import ContactsUI
import Contacts
class AddIntentionController: UITableViewController, CLLocationManagerDelegate,UIGestureRecognizerDelegate {

    
    
    @IBOutlet weak var view_IntentionName: UIView!
    
    @IBOutlet weak var view_Inviteothers: UIView!
    
    @IBOutlet weak var view_Date: UIView!
    
    @IBOutlet weak var view_Location: UIView!
    
    @IBOutlet weak var view_Budget: UIView!
    
    @IBOutlet weak var view_Type: UIView!
    var contactStore = CNContactStore()
    func askForContactAccess() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .denied, .notDetermined:
            self.contactStore.requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                if !access {
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            let alertController = UIAlertController(title: "Contacts", message: message, preferredStyle: UIAlertControllerStyle.alert)
                            
                            let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
                            }
                            
                            alertController.addAction(dismissAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        })  
                    }  
                }  
            })  
            break  
        default:  
            break  
        }  
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.selectedIndex = 0
    }
    func taptoTypename(){
        intentionName.becomeFirstResponder()
    }
    @IBAction func inviteAdd(_ sender: Any) {
        //self.performSegue(withIdentifier: "searchuser", sender: nil)
         taptoInvitation()
    }
    func taptoInvitation(){
        let controller = UIAlertController(title: "Invitation Type", message: "Phone Contact or User Invite or Facebook?", preferredStyle: UIAlertControllerStyle.alert)
        let contact_alert = UIAlertAction(title: "Phone Contact", style: UIAlertActionStyle.default) { (action) in
            let cnPicker = CNContactPickerViewController()
            cnPicker.predicateForEnablingContact = NSPredicate(format: "emailAddresses.@count > 0")
            cnPicker.delegate = self
            self.present(cnPicker, animated: true, completion: nil)
        }
        let email_alert = UIAlertAction(title: "App User", style: UIAlertActionStyle.default) { (action) in
            self.performSegue(withIdentifier: "searchuser", sender: nil)
        }
        controller.addAction(contact_alert)
        controller.addAction(email_alert)
        self.present(controller, animated: true, completion: nil)
    }

    @IBAction func setDate(_ sender: Any) {
        showEventdaypickerDlg()
    }
    func taptoDateSelect(){
        showEventdaypickerDlg()
    }
    @IBAction func setLocation(_ sender: Any) {
        taptoLocationSelect()
    }
    func taptoLocationSelect(){
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        present(autoCompleteController, animated: true, completion: nil)
    }
    
    @IBAction func setType(_ sender: Any) {
        taptoTypeSelect()
    }
    func taptoTypeSelect(){
        let controller : RMPickerViewController = RMPickerViewController(style: RMActionControllerStyle.white)!
        controller.title = "Select Category";
        let select : RMAction<UIPickerView> = RMAction<UIPickerView>(title: "Done", style: .done) { (controller1) in
            //controller.dismiss(animated: true, completion: nil)
            self.label_Wedding.text = self.categoryArray[controller.picker.selectedRow(inComponent: 0)]
            }!
        controller.addAction(select)
        controller.picker.dataSource = self
        controller.picker.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    var tagArray : [AHTag] = []
    var invitedArray : [User] = []
    var email_invitedArray : [String] = []
    var date_Intention : Date!
    
    var categoryArray : [String] = []
    @IBOutlet weak var tagview_Others: AHTagsLabel!
    @IBOutlet weak var label_Date: UILabel!
    @IBOutlet weak var label_Location: UILabel!
    @IBOutlet weak var label_Wedding: UILabel!
    @IBOutlet weak var intentionName: UITextField!
    @IBOutlet weak var from_budget: UITextField!
    @IBOutlet weak var to_budget: UITextField!
    
    @IBAction func submitIntention(_ sender: Any) {
        SVProgressHUD.show()
        var check : Int = 1;
        if (intentionName.text?.isEmpty)!{
            SWMessage.sharedInstance.showNotificationInViewController(self, title: "No invitation Name", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            check = check * 0;
        }
        else if (invitedArray.count == 0 && email_invitedArray.count == 0){
            SWMessage.sharedInstance.showNotificationInViewController(self, title: "No Inviter", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            check = check * 0;
        }
        else if (label_Location.text?.isEmpty)!{
            SWMessage.sharedInstance.showNotificationInViewController(self, title: "No Location", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            check = check * 0;
        }
        else if (label_Wedding.text?.isEmpty)!{
            SWMessage.sharedInstance.showNotificationInViewController(self, title: "No Type", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            check = check * 0;
        } else if (label_Date.text?.isEmpty)!{
            SWMessage.sharedInstance.showNotificationInViewController(self, title: "No Date", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            check = check * 0;
        } else if ((to_budget.text?.isEmpty)! || (from_budget.text?.isEmpty)!){
            SWMessage.sharedInstance.showNotificationInViewController(self, title: "Budget is not set", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            check = check * 0;
        } else{
            if (Int(to_budget.text!)! <= 0 || Int(from_budget.text!)! <= 0){
                SWMessage.sharedInstance.showNotificationInViewController(self, title: "Budget cannot be below and same with 0", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                check = check * 0;
            }
            if (Int(to_budget.text!)! <  Int(from_budget.text!)!){
                SWMessage.sharedInstance.showNotificationInViewController(self, title: "Budget values are not set properly", subtitle: "", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                check = check * 0;
            }
        }
        
        if (check == 1){
            
            var intention = Intention(value: [
                "name" : self.intentionName.text!,
                "date" : self.label_Date.text?.shortdateFromISO8601?.iso8601,
                "location" : self.label_Location.text!,
                "category" : self.label_Wedding.text!,
                "maxBudget" : Int(self.to_budget.text!),
                "minBudget" : Int(self.from_budget.text!),
                "user" : LocalStorge.user.email
                ])
            
            let key = Database.database().reference().child("intentions").childByAutoId().key
            Database.database().reference().child("intentions").child(key).setValue(intention.toJSON())
            
            
            var userlist : [String] = []
            var emaillist : [String] = []
            
            self.invitedArray.forEach({ (user) in
                userlist.append(user.email)
            })
            self.email_invitedArray.forEach({ (email) in
                
                emaillist.append(email)
            })
            
            emaillist.forEach({ (email) in
                if userlist.contains(email){
                    emaillist.remove(at: emaillist.index(of: email)!)
                }
            })
            var invite = Inviter(value : ["pendinglist" : emaillist, "userlist" : userlist])
            Database.database().reference().child("users").child(LocalStorge.appID).child("inviters").child(key).setValue(invite.toJSON())
            self.navigationController?.popViewController(animated: true)
            SVProgressHUD.dismiss()
        }
        else {
            SVProgressHUD.dismiss()
        }
    }
    func shadow(vwBack : UIView) {
        vwBack.layer.masksToBounds = false
        vwBack.layer.shadowColor = UIColor.black.cgColor
        vwBack.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        vwBack.layer.shadowOpacity = 0.7
        vwBack.layer.shadowRadius = 1.0
    }

    func showEventdaypickerDlg() {
        
        let minDate = Calendar.current.date(byAdding: Calendar.Component.year, value: 20, to: Date())
        let maxDate = Calendar.current.date(byAdding: Calendar.Component.year, value: -30, to: Date())
        DatePickerDialog().show("Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), minimumDate: minDate, maximumDate: maxDate, datePickerMode: UIDatePickerMode.date) { (date) in
            
            if date != nil{
                self.date_Intention = date
                
                self.label_Date.text = date?.shortiso8601
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.askForContactAccess()
        tagview_Others.isUserInteractionEnabled = false
        shadow(vwBack: view_IntentionName)
        shadow(vwBack: view_Inviteothers)
        shadow(vwBack: view_Date)
        shadow(vwBack: view_Location)
        shadow(vwBack: view_Budget)
        shadow(vwBack: view_Type)

        self.navigationController?.isNavigationBarHidden = false
        
        
        let invite_gesture = UITapGestureRecognizer(target: self, action: #selector(taptoInvitation))
        invite_gesture.delegate = self
        view_Inviteothers.addGestureRecognizer(invite_gesture)
        
        let intentionname_gesture = UITapGestureRecognizer(target: self, action: #selector(taptoTypename))
        intentionname_gesture.delegate = self
        view_IntentionName.addGestureRecognizer(intentionname_gesture)

        let date_gesture = UITapGestureRecognizer(target: self, action: #selector(taptoDateSelect))
        date_gesture.delegate = self
        view_Date.addGestureRecognizer(date_gesture)
        
        let location_gesture = UITapGestureRecognizer(target: self, action: #selector(taptoLocationSelect))
        location_gesture.delegate = self
        view_Location.addGestureRecognizer(location_gesture)
        
        let typeselect_gesture = UITapGestureRecognizer(target: self, action: #selector(taptoTypeSelect))
        typeselect_gesture.delegate = self
        view_Type.addGestureRecognizer(typeselect_gesture)

        
        self.intentionName.delegate = self
    
        self.to_budget.delegate = self
        
        self.from_budget.delegate = self
        
        self.categoryArray = []
        Database.database().reference().child("categorylist").observe(.value, with: { (snap) in
            (snap.value as! [String:Any]).keys.forEach({ (keyStr) in
                
                self.categoryArray.append((snap.value as! [String:Any])[keyStr] as! String)
                
            })
            if self.categoryArray.count > 0{
                self.label_Wedding.text = self.categoryArray[0]
            }
        })
        
        var toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        toolbar.barStyle = .blackTranslucent
        
        var flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        var done = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(keyboarddone))
        toolbar.items = [flexSpace, done]
        toolbar.sizeToFit()
        
        self.from_budget.inputAccessoryView = toolbar
        self.to_budget.inputAccessoryView = toolbar
        

    }
    func keyboarddone(){
        self.from_budget.resignFirstResponder()
        self.to_budget.resignFirstResponder()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! UserSearchController
        controller.invitedArray = self.invitedArray
        controller.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 30
        }
        if indexPath.row == 1{
            return 60
        }
        if indexPath.row == 2{
            return 60
        }
        if indexPath.row > 2 && indexPath.row <= 6{
            return 60
        }
        if indexPath.row == 7{
            return 50
        }
        if indexPath.row == 8{
            return 190
        }
        if indexPath.row == 9{
            return 80
        }
        return 60
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 30
        }
        if indexPath.row == 1{
            return 60
        }
        if indexPath.row == 2{
            return UITableViewAutomaticDimension
        }
        if indexPath.row > 2 && indexPath.row <= 6{
            return 60
        }
        if indexPath.row == 7{
            return 50
        }
        if indexPath.row == 8{
            return 190
        }
        if indexPath.row == 9{
            return 80
        }
        return UITableViewAutomaticDimension
    }
    
    func isinUserArray(userArray : [User], user : User) -> Bool{
        var flag = false
        userArray.forEach { (user_orig) in
            if user_orig == user{
                flag = true
            }
        }
        return flag
    }

}
extension AddIntentionController : GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        label_Location.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
    }
    
    /*func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        
    }*/
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
          dismiss(animated: true, completion: nil)
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
          UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
         UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
extension AddIntentionController : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
extension AddIntentionController : UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.categoryArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        label_Wedding.text = self.categoryArray[row]
    }
}
extension AddIntentionController : InvitedUserDelegate{
    func onDismissSearchController(invitedArr: [User]) {
        
        var userArray_temp : [User] = []
        invitedArr.forEach { (user_target) in
            if self.isinUserArray(userArray: self.invitedArray, user: user_target) == false{
                userArray_temp.append(user_target)
            }
        }
        self.invitedArray += userArray_temp
        var tags : [AHTag] = []
        if self.tagview_Others.tags == nil{
            tags = []
        }
        else{
            tags = self.tagview_Others.tags!
        }
        userArray_temp.forEach { (user) in
            let tag = AHTag(dictionary: ["URL" : "url", "TITLE" : user.name,"COLOR":"0xFF8F8F","ENABLED" : false, "CATEGORY" : "category"])
            tags.append(tag)
        }
        self.tagview_Others.setTags(tags)
        
        tableView.reloadData()
    }
}
extension AddIntentionController : UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
extension AddIntentionController : FBSDKSharingDelegate{
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!)
    {
        print(results)

    }
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!)
    {
        let alert = UIAlertController(title: "Intention Error", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!){
        let alert = UIAlertController(title: "Intention was Cancelled", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
}
extension AddIntentionController : FBSDKAppInviteDialogDelegate{

    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        if (error != nil){
            
            print()
        }
    }
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        if (results != nil){
            let resultObject = NSDictionary(dictionary: results)
            
            if let didComplete = resultObject.value(forKey: "didComplete")
            {
                if let didCancel = resultObject.value(forKey: "cancel"){
                    print("User canceled invitation dialog")
                    let alert = UIAlertController(title: "Invitation was Cancelled", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    print("Invitation dialog was sent")
                    
                    let alert = UIAlertController(title: "Invitation was sent", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else{
            let alert = UIAlertController(title: "Invitation was Cancelled", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
extension AddIntentionController : CNContactPickerDelegate{
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        var contacts_temp : [CNContact] = []
        contacts.forEach { contact in
            if (self.email_invitedArray.contains(contact.emailAddresses[0].value as! String)){
                
            } else {
                self.email_invitedArray.append(contact.emailAddresses[0].value as! String)
                contacts_temp.append(contact)
            }
        }
        var tags : [AHTag] = []
        if self.tagview_Others.tags == nil{
            tags = []
        }
        else{
            tags = self.tagview_Others.tags!
        }
        contacts_temp.forEach { (contact) in
            let tag = AHTag(dictionary: ["URL" : "url", "TITLE" : contact.emailAddresses[0].value as! String,"COLOR":"0xFF8F8F","ENABLED" : false, "CATEGORY" : "category"])
            tags.append(tag)
        }
        self.tagview_Others.setTags(tags)
        tableView.reloadData()
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
}
