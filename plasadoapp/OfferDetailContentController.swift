//
//  OfferDetailContentController.swift
//  plasado
//
//  Created by a on 8/7/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
class OfferDetailContentController: UITableViewController {

    
    
    var object : Offer!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0)
        {
            return 270
        }
        else{
            return 250
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier : String = ""

        if (indexPath.row == 0)
        {
            identifier = "OfferDetailHeaderCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OfferDetailHeaderCell
            cell.offerTitle.text = self.object.title
            cell.offerPrice1.text = "\(self.object.price)"
            cell.offerComment.text = self.object.comment
            
            return cell
            
        }
        else{
            identifier = "OfferDetailFooterCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OfferDetailFooterCell
            cell.gallaryImage.downloadedFrom(link:  (self.object.picture), contentMode: .scaleToFill)
            
            return cell
        }

        // Configure the cell...
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
