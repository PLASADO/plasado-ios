



//
//  MenuViewController.swift
//  plasado
//
//  Created by Emperor on 8/5/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
import SideMenu
class MenuViewController: UITableViewController {

    var delegate : SideMenuDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard tableView.backgroundView == nil else {
            return
        }
        
        tableView.backgroundColor = UIColor.init(red: 179/255, green: 33/255, blue: 33/255, alpha: 0.8)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    @IBAction func settingsPress(_ sender: Any) {
        
    }
    @IBAction func profilePress(_ sender: Any) {
    }
    @IBAction func message(_ sender: Any) {
    }
    @IBAction func intentionPress(_ sender: Any) {
    }
    @IBAction func calendarPress(_ sender: Any) {
    }
    @IBAction func homePress(_ sender: Any) {
    }
    @IBAction func backPress(_ sender: Any) {
        
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
