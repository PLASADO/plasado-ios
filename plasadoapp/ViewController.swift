//
//  ViewController.swift
//  plasadoapp
//
//  Created by a on 8/11/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SWMessages
import Firebase
import Morph
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseDatabase
import ObjectMapper
import EventKit
import Contacts
//Firebase URI https://plasado-eea28.firebaseapp.com/__/auth/handler

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var emailView: UIView!
    
    @IBOutlet weak var passwordView: UIView!
    
    @IBOutlet weak var facebookloginView: UIView!
    
    @IBAction func onLogin(_ sender: Any) {
        self.facebookLogin = false
        if self.email.text == "" || self.password.text == "" {
            SWMessage.sharedInstance.showNotificationInViewController(self, title: "Login Failed", subtitle: "Please enter an email and password.", image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
            
        } else {
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: email.text!, password: password.text!, completion: { (user, err) in
                SVProgressHUD.dismiss()
                if err == nil{
                    let uid = user?.uid
                    LocalStorge.appID = uid
                    SWMessage.sharedInstance.showNotificationInViewController(self, title: "Login Success", subtitle: "", image: nil, type: .success, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                    Database.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: user?.email).observeSingleEvent(of: DataEventType.value,  with: { (snap) in
                        if snap.exists() == true{
                            LocalStorge.user = User(value: snap.value as! [String : Any])
                            self.performSegue(withIdentifier: "signin", sender: nil)
                        } else {
                            SWMessage.sharedInstance.showNotificationInViewController(self, title: "No information for this user", subtitle:err?.localizedDescription, image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                        }
                    })
                } else {
                    SWMessage.sharedInstance.showNotificationInViewController(self, title: "Login Failed", subtitle:err?.localizedDescription, image: nil, type: .success, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                }
                
            })
            
        }
        
    }
    @IBAction func onSignup(_ sender: Any) {
        performSegue(withIdentifier: "signup", sender: nil)
    }
    var facebookLogin : Bool! = false
    var user : User!
    var handle : AuthStateDidChangeListenerHandle!
    
    func shadow(vwBack : UIView) {
        vwBack.layer.masksToBounds = false
        vwBack.layer.shadowColor = UIColor.black.cgColor
        vwBack.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        vwBack.layer.shadowOpacity = 0.7
        vwBack.layer.shadowRadius = 1.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        shadow(vwBack: emailView)
        shadow(vwBack: passwordView)
        email.delegate = self
        password.delegate = self
        let tap_Facebookbtn = UITapGestureRecognizer(target: self, action: #selector(TapFacebookBtn))
        tap_Facebookbtn.delegate = self
        facebookloginView.addGestureRecognizer(tap_Facebookbtn)
    }

    func TapFacebookBtn(){
        self.facebookLogin = true
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email","user_events","user_birthday","user_friends"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            if (result?.isCancelled)!{
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    SWMessage.sharedInstance.showNotificationInViewController(self, title: "Login Failed", subtitle: error.localizedDescription, image: nil, type: .error, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                    return
                }
                SWMessage.sharedInstance.showNotificationInViewController(self, title: "Login Success", subtitle: "", image: nil, type: .success, duration: .custom(1), callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .top, canBeDismissedByUser: true)
                self.returnUserData(uid: (user?.uid)!)
            })
        }
    }
    func returnUserData(uid : String)
    {
        LocalStorge.appID = uid
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name,last_name,name,gender,picture.type(large),email,birthday,events,locale,friends"],httpMethod: "GET")
        graphRequest.start { (connection, result, error) in
            if ((error) != nil)
            {
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let user = User(value: result as! [String:Any])
                Database.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: user.email).observeSingleEvent(of: DataEventType.value, with: { (snap) in
                    let rootRef = Database.database().reference()

                    if snap.exists() == false{
                        user.setDaysoffweek(daysoffweekArray: ["Sat","Sun"])
                        rootRef.child("users").child(uid).setValue(user.toJSON())
                        LocalStorge.user = user
                        self.performSegue(withIdentifier: "tutorialpage", sender: nil)
                    } else{
                        rootRef.child("users").child(uid).updateChildValues(user.toJSON())
                        LocalStorge.user = user
                        self.performSegue(withIdentifier: "signin", sender: nil)
                    }
                })
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        scoreText.endEditing(true)
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
