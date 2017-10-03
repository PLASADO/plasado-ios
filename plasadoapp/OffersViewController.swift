//
//  OffersViewController.swift
//  plasadoapp
//
//  Created by a on 8/13/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit

class OffersViewController: UIViewController, UISearchBarDelegate {

    
    @IBOutlet weak var searchController: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive : Bool = false
    
    var data : [String] = []
    var indexArray : [Int] = []
    var filtered : [String] = []
    
    var indexOffer : Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        

        tableView.backgroundColor = UIColor.white

        navigationController?.isNavigationBarHidden = true
        tabControllerNavBarShow()
        
        searchController.delegate = self as! UISearchBarDelegate
        
        var index = 0
        LocalStorge.offerArray.forEach { (offer) in
            data.append(offer.title);
            indexArray.append(index)
            index = index + 1
        }
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        tabControllerNavBarShow()
    }
    func tabControllerNavBarShow() {
        navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = false
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = ""
        
        let attrs = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attrs
        
        if (segue.identifier == "offerdetail") {
            let controller = segue.destination as! OfferDetailController
            
            if(searchActive) {
                controller.offerObject = LocalStorge.offerArray[indexOffer]
            } else{
                controller.offerObject = LocalStorge.offerArray[self.indexArray[indexOffer]]
            }
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
        searchActive = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered.removeAll()
        indexArray.removeAll()
        filtered = data.filter({
            $0.localizedCaseInsensitiveContains(searchText)
        })
        if (filtered.count > 0){
            for i in 0...filtered.count - 1{
                if (data.count > 0){
                    for j in 0...data.count - 1{
                        if filtered[i].lowercased() == data[j].lowercased(){
                            indexArray.append(j)
                        }
                    }
                    
                }
            }
        }
        
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

    
    
}
extension OffersViewController : DeailsButtonDelegate{
    func onDetailButtonClicked(num : Int!) {
        self.indexOffer = num
        self.performSegue(withIdentifier: "offerdetail", sender: nil)
    }
}
extension OffersViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}
extension OffersViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(searchActive) {
            return filtered.count
        }
        return data.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offercell") as! OfferCell
        cell.delegate = self
        if(searchActive){
            let object = LocalStorge.offerArray[indexArray[indexPath.row]]
            cell.offerImage.downloadedFrom(link:  object.picture, contentMode: .scaleToFill)
            cell.offerTitle.text = object.title as! String
            cell.discount.text = "\(object.discount as! Int)%"
            cell.index = indexArray[indexPath.row]
            
        } else {
            let object = LocalStorge.offerArray[indexPath.row]
            cell.offerImage.downloadedFrom(link:  object.picture, contentMode: .scaleToFill)
            cell.offerTitle.text = object.title
            cell.discount.text = "\(object.discount)%"
            cell.index = indexPath.row
        }
        
        return cell;
    }

}

