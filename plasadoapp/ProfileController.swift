//
//  ProfileController.swift
//  plasado
//
//  Created by a on 8/6/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {

    
    @IBOutlet weak var profileImageview: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var profileComment: UITextView!
    
    @IBOutlet weak var profile_Tableview: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = ""
        
        let attrs = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attrs
        
    }
    
    
    @IBAction func AboutyouClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "aboutyou", sender: nil)
    }
    
    
    
    var searchArray = [String]() {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.init("searchResultsUpdated"), object: searchArray)
        }
    }
    
    var countrySearchController: UISearchController = ({
        /* Display search results in a separate view controller */
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.sizeToFit()
        
        return controller
    })()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profile_Tableview.tableHeaderView = countrySearchController.searchBar
        countrySearchController.searchResultsUpdater = self as? UISearchResultsUpdating
        
        navigationController?.isNavigationBarHidden = true
        tabControllerNavBarShow()
        
        /*profileImageview.downloadedFrom(link: LocalStorge.host + "/" + (LocalStorge.user["profileURL"] as! String), contentMode: .scaleToFill)
        profileComment.text = LocalStorge.user["comments"] as! String
        username.text = LocalStorge.user["username"] as! String
        */
        
        profileImageview.downloadedFrom(link: LocalStorge.user.picture as! String,contentMode: .scaleToFill)
        profileComment.text = LocalStorge.user.comments
        username.text = LocalStorge.user.name
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        tabControllerNavBarShow()
    }
    func tabControllerNavBarShow() {
        navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ProfileController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch countrySearchController.isActive {
        case true:
            //return searchArray.count
            return 3
        case false:
            //return Countries.list.count
            return 5
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "profilecell", for: indexPath) as! ProfileSearchCell
        
        switch countrySearchController.isActive {
        case true:
            //cell.configureCell(with: countrySearchController.searchBar.text!, cellText: searchArray[indexPath.row])
            return cell
        case false:
            //cell.textLabel?.text! = Countries.list[indexPath.row]
            return cell
        }
    }
}

extension ProfileController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "myintention", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfileController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController)
    {
        if searchController.searchBar.text?.utf8.count == 0 {
            //searchArray = Countries.list
            profile_Tableview.reloadData()
        } else {
            searchArray.removeAll(keepingCapacity: false)
            
            let range = searchController.searchBar.text!.characters.startIndex ..< searchController.searchBar.text!.characters.endIndex
            var searchString = String()
            
            searchController.searchBar.text?.enumerateSubstrings(in: range, options: .byComposedCharacterSequences, { (substring, substringRange, enclosingRange, success) in
                searchString.append(substring!)
                searchString.append("*")
            })
            
            let searchPredicate = NSPredicate(format: "SELF LIKE[cd] %@", searchString)
            //let array = (Countries.list as NSArray).filtered(using: searchPredicate)
            //searchArray = array as! [String]
            profile_Tableview.reloadData()
        }
    }
}


