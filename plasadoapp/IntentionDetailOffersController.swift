//
//  IntentionDetailOffersController.swift
//  plasadoapp
//
//  Created by a on 8/14/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit

class IntentionDetailOffersController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    var parentController : UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
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
    }
}
extension IntentionDetailOffersController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}
extension IntentionDetailOffersController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "offercell", for: indexPath) as! OfferCell
        cell.delegate = self
        
        return cell
    }
    
}
extension IntentionDetailOffersController : DeailsButtonDelegate{
    func onDetailButtonClicked(num: Int!) {
        self.index
        self.parentController.parent?.performSegue(withIdentifier: "offerdetail", sender: nil)
    }


    
}
