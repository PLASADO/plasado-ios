//
//  SignupController.swift
//  plasado
//
//  Created by Emperor on 8/2/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
import Morph
import DatePickerDialog
import SWMessages
import Photos
import Alamofire
import Firebase
import FirebaseStorage
import FirebaseAuth
import SVProgressHUD
import SDWebImage
import FBSDKCoreKit
import FBSDKLoginKit

class SignupController: UITableViewController {
    
    
    @IBOutlet weak var text_Firstname: UITextField!
    
    @IBOutlet weak var text_Lastname: UITextField!
    
    @IBOutlet weak var text_Birthdate: UITextField!
    
    @IBOutlet weak var text_Gender: UITextField!
    
    @IBOutlet weak var text_Email: UITextField!
    
    @IBOutlet weak var text_Password: UITextField!
    
    @IBOutlet weak var btn_Createaccount: UIButton!
    
    @IBOutlet weak var avatar_addBtn: UIButton!
    
    @IBOutlet weak var avatar_Button: UIButton!
    
    @IBOutlet weak var view_firstName: UIView!
    
    @IBOutlet weak var view_lastName: UIView!
    
    @IBOutlet weak var view_birthdate: UIView!
    
    @IBOutlet weak var view_gender: UIView!
    
    @IBOutlet weak var view_email: UIView!
    
    @IBOutlet weak var view_password: UIView!
    
    
    let imagePicker : UIImagePickerController = UIImagePickerController()
    
    
    var profileImage : UIImage!
    var imageType : String!
    var imageURL : URL!
    var data : Data!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        text_Birthdate.delegate = self
        text_Firstname.delegate = self
        text_Lastname.delegate = self
        text_Gender.delegate = self
        text_Email.delegate = self
        text_Password.delegate = self
        
        imagePicker.delegate = self
        imagePicker.navigationBar.isTranslucent = false
        
        shadow(vwBack: view_firstName)
        shadow(vwBack: view_lastName)
        shadow(vwBack: view_birthdate)
        shadow(vwBack: view_gender)
        shadow(vwBack: view_email)
        shadow(vwBack: view_password)
    }
    func shadow(vwBack : UIView) {
        vwBack.layer.masksToBounds = false
        vwBack.layer.shadowColor = UIColor.black.cgColor
        vwBack.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        vwBack.layer.shadowOpacity = 0.7
        vwBack.layer.shadowRadius = 1.0
    }
    
    @IBAction func onCreateAccount(_ sender: Any) {
        
        let firstName : String! = text_Firstname.text
        let lastName : String! = text_Lastname.text
        let birthDay : String! = text_Birthdate.text
        let gender : String! = text_Gender.text
        let email : String! = text_Email.text
        let password : String! = text_Password.text
        
        SWMessage.sharedInstance.defaultViewController = self
        edgesForExtendedLayout = .all
        navigationController?.navigationController?.navigationBar.isTranslucent = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        // Create the file metadata
        
        
        if (is_validateFirstName(firstname: firstName) && is_validateLastName(lastname: lastName) && is_validateBirthdate(birthdate: birthDay) && is_validateGender(gender: gender) && is_validateEmail(email: email) && is_validatePassword(password: password) && self.imageURL != nil)
        {
            Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
                if let err = err{
                    SWMessage.sharedInstance.showNotificationInViewController(self, title: "Authentication failed", subtitle: err.localizedDescription, image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                }
                else{
                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
                        SWMessage.sharedInstance.showNotificationInViewController(self, title: "Authentication Success", subtitle: "", image: nil, type: .success, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                        let storage = Storage.storage()
                        
                        let storageRef = storage.reference()
                        
                        // Local file you want to upload
                        let localFile = self.imageURL
                        
                        // Create the file metadata
                        let metadata = StorageMetadata()
                        metadata.contentType = self.imageType
                        
                        // Upload file and metadata to the object 'images/mountains.jpg'
                        
                        var fileName = firstName! + lastName! + "\(Date().timeIntervalSince1970)"
                        
                        if (localFile?.absoluteString.lowercased().contains("png"))!{
                            self.imageType = "image/png";
                        }
                        if (localFile?.absoluteString.lowercased().contains("jpg"))!{
                            self.imageType = "image/jpg";
                        }
                        if (localFile?.absoluteString.lowercased().contains("jpeg"))!{
                            self.imageType = "image/jpeg";
                        }
                        
                        if (self.imageType == "image/png"){
                            fileName = fileName + ".png";
                        }
                        else if (self.imageType == "image/jpg") {
                            fileName = fileName + ".jpg";
                        }
                        else if (self.imageType == "image/jpeg") {
                            fileName = fileName + ".jpeg";
                        }
                        SVProgressHUD.show()
                        
                        //let uploadTask = storageRef.child("images/profileimage").child(fileName).putFile(from: localFile!, metadata: metadata)
                        let uploadTask = storageRef.child("images/profileimage").child(fileName).putData(self.data, metadata: metadata)
                        // Listen for state changes, errors, and completion of the upload.
                        uploadTask.observe(.resume) { snapshot in
                            // Upload resumed, also fires when the upload starts
                        }
                        
                        uploadTask.observe(.pause) { snapshot in
                            // Upload paused
                        }
                        
                        uploadTask.observe(.progress) { snapshot in
                            // Upload reported progress
                            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                                / Double(snapshot.progress!.totalUnitCount)
                        }
                        uploadTask.observe(.success) { snapshot in
                            SVProgressHUD.dismiss()
                            let urlStr = snapshot.metadata?.downloadURL()?.absoluteString
                            let uid = user?.uid
                            let rootRef = Database.database().reference()
                            let countryCode = (Locale.current as! NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
                            let reg_User = User(value: [
                                "email" : email,
                                "name" : firstName + " " + lastName,
                                "birthday" : birthDay,
                                "gender" : gender,
                                "type" : "user",
                                "comments" : "",
                                "picture" : ["data" : ["url" : urlStr]],
                                "events" : ["data" : []]
                                ])
                            LocalStorge.user = reg_User
                            reg_User.setDaysoffweek(daysoffweekArray: ["Sat","Sun"])
                            rootRef.child("users").child(uid!).setValue(reg_User.toJSON())
                            
                            self.parent?.performSegue(withIdentifier: "tutorialpage", sender: nil)
                        }
                        uploadTask.observe(.failure, handler: { (snapshot) in
                            SVProgressHUD.dismiss()
                            
                            let user = Auth.auth().currentUser
                            
                            user?.delete { error in
                                if let error = error {
                                    // An error happened.
                                } else {
                                    // Account deleted.
                                }
                            }
                            SWMessage.sharedInstance.showNotificationInViewController(self, title: "Authentication failed", subtitle: "Upload failed", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                        })
                    })
                    
                }
            }
            
            
            
        }
        else
        {
            
            var title : String! = "Validation Failed"
            var subTitle : String!
            
            if (!is_validatePassword(password: password)){
                subTitle = "Password is empty"
            }
            
            if (!is_validateEmail(email: email)){
                subTitle = "Email is empty or not valid"
            }
            
            if (!is_validateGender(gender: gender)){
                subTitle = "Gender is empty"
            }
            
            if (!is_validateBirthdate(birthdate : birthDay)){
                subTitle = "Birthday is empty"
            }
            
            if (!is_validateLastName(lastname: lastName)){
                subTitle = "Lastname is empty or not valid"
            }
            
            if (!is_validateFirstName(firstname: firstName)){
                subTitle = "Firstname is empty or not valid"
            }
            SWMessage.sharedInstance.showNotificationInViewController(self, title: title, subtitle: subTitle, image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            
            
        }
        
    }
    
    @IBAction func onAvatarClicked(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func onAddImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func is_validateFirstName(firstname : String!) -> Bool{
        if (firstname != nil && firstname.isEmpty == false)
        {
            return true
        }
        return false
    }
    func is_validateLastName(lastname : String!) -> Bool{
        if (lastname != nil && lastname.isEmpty == false)
        {
            return true
        }
        return false
    }
    func is_validateBirthdate(birthdate : String!) -> Bool{
        if (birthdate != nil && birthdate.isEmpty == false)
        {
            return true
        }
        return false
    }
    func is_validateGender(gender : String!) -> Bool{
        if (gender != nil && gender.isEmpty == false)
        {
            return true
        }
        return false
    }
    func is_validateEmail(email : String!) -> Bool{
        if (email != nil && email.isEmpty == false)
        {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with:email)
        }
        return false
    }
    func is_validatePassword(password : String!) -> Bool{
        if (password != nil && password.isEmpty == false)
        {
            return true
        }
        return false
    }
    func showBirthdaypickerDlg() {
        let minDate = Calendar.current.date(byAdding: Calendar.Component.year, value: 20, to: Date())
        let maxDate = Calendar.current.date(byAdding: Calendar.Component.year, value: -30, to: Date())
        DatePickerDialog().show("Birth Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: Date(), minimumDate: minDate, maximumDate: maxDate, datePickerMode: UIDatePickerMode.date) { (date) in
            if date != nil{
                self.text_Birthdate.text = date?.shortiso8601
            }
            
        }
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
        return 8
    }
    
    
}
extension SignupController : UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        scoreText.endEditing(true)
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == text_Birthdate){
            text_Birthdate.resignFirstResponder()
            showBirthdaypickerDlg()
            return false;
        }
        if (textField == text_Gender){
            text_Gender.resignFirstResponder()
            let actionController = UIAlertController(title: "Select Gender", message: "Please select male or female", preferredStyle: UIAlertControllerStyle.actionSheet)
            actionController.view.subviews.first?.backgroundColor = UIColor.darkGray
            actionController.addAction(UIAlertAction(title: "Male", style: UIAlertActionStyle.default, handler: { (action) in
                self.text_Gender.text = "Male"
            }))
            actionController.addAction(UIAlertAction(title: "Female", style: UIAlertActionStyle.default, handler: { (action) in
                self.text_Gender.text = "Female"
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
extension SignupController : UIActionSheetDelegate{
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        
    }
}
extension SignupController : UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            avatar_Button.setImage(pickedImage, for: .normal)
            //avatar_Profile.image = pickedImage
            profileImage = pickedImage
            let imageurl = info[UIImagePickerControllerReferenceURL] as! URL
            if (imageurl.absoluteString.lowercased().contains("png")){
                self.imageType = "image/png";
            }
            if (imageurl.absoluteString.lowercased().contains("jpg")){
                self.imageType = "image/jpg";
            }
            
            let assets = PHAsset.fetchAssets(withALAssetURLs: [imageurl], options: nil)
            let asset = assets.firstObject
            
            asset?.requestContentEditingInput(with: nil, completionHandler: { (ContentEditingInput, info) in
                self.imageURL = ContentEditingInput?.fullSizeImageURL
            })
            
            self.data = UIImageJPEGRepresentation(profileImage, 0.8)

            
        }
        
        avatar_addBtn.isHidden = true
        dismiss(animated: true, completion: nil)
        
    }
    func uploadSuccess(_ metadata: StorageMetadata, storagePath: String) {
        print("Upload Succeeded!")
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension SignupController : UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationController.navigationBar.barTintColor = UIColor.init(red: 180/255, green: 43/255, blue: 38/255, alpha: 1)
        navigationController.navigationBar.tintColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
}
extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
}

