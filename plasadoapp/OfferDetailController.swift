//
//  OfferDetailController.swift
//  plasado
//
//  Created by a on 8/7/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
class OfferDetailController: UIViewController {

    
    @IBOutlet weak var offerImage: UIImageView!
    var offerObject : Offer!
    
    @IBOutlet weak var offerLabel1: UILabel!
    
    @IBOutlet weak var offerLabel2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 179/255, green: 33/255, blue: 33/255, alpha: 1)
        let attrs = [NSForegroundColorAttributeName : UIColor.white]
        navigationItem.title = ""
        navigationController?.navigationBar.titleTextAttributes = attrs
        
        navigationController?.navigationBar.tintColor = UIColor.white
        tabControllerNavBarHide()
        navigationController?.isNavigationBarHidden = false
        
        offerImage.downloadedFrom(link:  (offerObject.picture), contentMode: .scaleToFill)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        tabControllerNavBarHide()
        navigationController?.isNavigationBarHidden = false
        
    }
    override func viewWillAppear(_ animated: Bool) {

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tabControllerNavBarShow() {
        navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = false
    }
    func tabControllerNavBarHide() {
        navigationController?.tabBarController?.navigationController?.isNavigationBarHidden = true
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "detailsubsegue"){
            let controller = segue.destination as! OfferDetailSubController
            controller.object = self.offerObject
            
        }
    }
    
 
    

}
