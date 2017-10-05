//
//  HomeController.swift
//  plasado
//
//  Created by a on 8/6/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import Firebase
import FirebaseDatabase
import ObjectMapper
import EventKit
import Contacts
class HomeController: UIViewController/*, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource*/ {

    
    @IBOutlet weak var home_Image: UIImageView!
    
    @IBOutlet weak var home_greeting: UILabel!
    
    @IBOutlet weak var home_matchInfo: UILabel!
    
    @IBOutlet weak var featuredOffer_CollectionView: UICollectionView!
    
    @IBOutlet weak var myIntents_TableView: UITableView!

    var indexFeatured : Int!
    var eventFetch : CalendarEventFetch! = CalendarEventFetch()
    func tabControllerNavBarShow() {
        navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func SeeOffer(_ sender: Any) {
        self.performSegue(withIdentifier: "seeoffers", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabControllerNavBarShow()
        self.navigationController?.isNavigationBarHidden = true
        home_Image.downloadedFrom(link: LocalStorge.user.picture as! String,contentMode: .scaleToFill)
        home_greeting.text = "Welcome Back " + (LocalStorge.user.name as! String)
        //self.checkCalendarAuthorizationStatus()
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let startOfMonth = Calendar.current.date(from: comp)!
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)!
        eventFetch.start_date = startOfMonth
        eventFetch.end_date = endOfMonth
        eventFetch.checkCalendarAuthorizationStatus()
        LocalStorge.ical_Events = eventFetch.ical_Events
        
        //self.fetchbirthdayListfromContact()
        SVProgressHUD.show()
        LocalStorge.offerArray = []
        Database.database().reference().child("offers").observe(.value, with: { (snap) in
            SVProgressHUD.dismiss()
            if snap.exists(){
                
                (snap.value as! [String : Any]).keys.forEach({ (str) in
                    var offer = Offer(JSON: ((snap.value as! [String : Any])[str] as! [String:Any]))
                    LocalStorge.offerArray.append(offer!)
                })
                
                LocalStorge.featuredOfferArray = LocalStorge.offerArray
                self.featuredOffer_CollectionView.reloadData()
            }
        })
        
        LocalStorge.intentionArray = []
        Database.database().reference().child("intentions").observe(DataEventType.value,with:{ (snap) in
            if snap.exists(){
                (snap.value as! [String : Any]).keys.forEach({ (str) in
                    var intention = Intention(JSON: ((snap.value as! [String : Any])[str] as! [String:Any]))
                    LocalStorge.intentionArray.append(intention!)
                })
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabControllerNavBarShow()
        self.navigationController?.isNavigationBarHidden = true

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = ""
        
        if segue.identifier == "offerdetailshow"{
            let controller = segue.destination as! OfferDetailController
            controller.offerObject = LocalStorge.featuredOfferArray[self.indexFeatured]
        }
    }
}
extension HomeController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocalStorge.intentionArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = LocalStorge.intentionArray[indexPath.row]
        let identifier : String = "intentioncell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MyIntentionCell
        
        //cell.intention_Title.text
        
        return cell
    }
}
extension HomeController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "myintention", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
extension HomeController : UICollectionViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LocalStorge.featuredOfferArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let offerObject  = LocalStorge.featuredOfferArray[indexPath.row]
        let identifier : String = "featuredCell"
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FeaturedOffersCell
        cell.feature_image.downloadedFrom(link: (offerObject.picture), contentMode: .scaleToFill)
        cell.feature_title.text = offerObject.title
        cell.feature_discount.text = "\(offerObject.discount)%"
        
        return cell
    }
    
}
extension HomeController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.indexFeatured = indexPath.row
        self.performSegue(withIdentifier: "offerdetailshow", sender: nil)
    }
}
