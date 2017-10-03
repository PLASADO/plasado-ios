//
//  UserSearchController.swift
//  plasadoapp
//
//  Created by Emperor on 8/30/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SDWebImage
import Firebase
protocol UserAddDelegate {
    func onUserAdded(num : Int)
}
protocol InvitedUserDelegate {
    func onDismissSearchController(invitedArr : [User])
}
class UserSearchController: UIViewController, UISearchBarDelegate {

    
    @IBOutlet weak var searchController: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onDone(_ sender: Any) {
        delegate.onDismissSearchController(invitedArr: invitedArray)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onSearchButton(_ sender: Any) {
        //self.UserArray = []
        SVProgressHUD.show()
        self.UserArray.removeAll()
/*        if searchText! == "" || searchText! == nil{
            self.UserArray = LocalStorge.user.friends
        } else{
            LocalStorge.user.friends.forEach { (friend) in
                if (friend.name.lowercased().contains(self.searchText.lowercased())){
                    self.UserArray.append(friend)
                }
            }
        }*/
        
        Database.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: self.searchText.lowercased()).observeSingleEvent(of: DataEventType.value,  with: { (snap) in
            if snap.exists(){
                (snap.value as! [String : Any]).keys.forEach({ (str) in
                    let target = (snap.value as! [String:Any])[str] as! [String : Any]
                    //User(value: target)
                    if (target["type"] as! String == "user"){
                        if (LocalStorge.appID != str){
                            self.UserArray.append(User(value : target))
                            
                            self.tableView.reloadData()
                        }
                    }
                    
                })
                SVProgressHUD.dismiss()
            }
            else {
                Database.database().reference().child("users").observe(.value, with: { (snap) in
                    
                    if snap.exists(){
                        (snap.value as! [String : Any]).keys.forEach({ (str) in
                            
                            if str.lowercased() == self.searchText.lowercased(){
                                let target = (snap.value as! [String:Any])[str] as! [String : Any]
                                if (target["type"] as! String == "user"){
                                    if (LocalStorge.appID != str){
                                        self.UserArray.append(User(value : target))
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                            
                            
                        })
                        
                    }
                    SVProgressHUD.dismiss()
                })

            }
        })

    }
    var searchActive : Bool = false
    
    var UserArray : [User]! = []
    
    var searchText : String!
    
    var ImageArray : [UIImage]! = []
    
    var invitedArray : [User]! = []
    
    var delegate : InvitedUserDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchController.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.searchText = ""
        
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
        searchActive = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}
extension UserSearchController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
extension UserSearchController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.UserArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "searchItemCell", for: indexPath) as! SearchItemCell
        if cell == nil{
            cell = SearchItemCell(style: UITableViewCellStyle.default, reuseIdentifier: "searchItemCell")
        }
        cell.addButton.setImage(UIImage(named:"plus1"), for: .normal)
        let object = self.UserArray[indexPath.row]
        
        if (!self.invitedArray.isEmpty){
            for index in 0...self.invitedArray.count - 1{
                if self.invitedArray[index] == object{
                    cell.addButton.setImage(UIImage(named:"checked"), for: .normal)
        
                } 
            }
        }
        
        cell.delegate = self

        cell.setImage(url: object.picture)
        cell.setIndex(num: indexPath.row)
        cell.setText(str: object.name)
        
        return cell;
    }
    
}
extension UserSearchController : UserAddDelegate{
    func onUserAdded(num: Int) {
        let cell = (self.tableView.cellForRow(at: IndexPath(row: num, section: 0)) as! SearchItemCell)
        
        if cell.addButton.image(for: .normal) == UIImage(named: "plus1") {
            let controller = UIAlertController(title: "Invite", message: "Do you want to invite this user?", preferredStyle: UIAlertControllerStyle.alert);
            controller.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                cell.onAddedUser()
                self.invitedArray.append(self.UserArray[num])
                controller.dismiss(animated: true, completion: nil)
            } ))
            controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                controller.dismiss(animated: true, completion: nil)
            } ))
            self.present(controller, animated: true, completion: nil)
        }
    }
}
