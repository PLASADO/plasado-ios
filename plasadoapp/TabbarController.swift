//
//  TabbarController.swift
//  plasadoapp
//
//  Created by a on 8/12/17.
//  Copyright © 2017 plasado. All rights reserved.
//

import UIKit
import SideMenu
protocol SideMenuDelegate {
    func onBack()
    func onHome()
    func onIntention()
    func onCalendar()
    func onMessage()
    func onProfile()
    func onSettings()
}
class TabbarController: UITabBarController , UITabBarControllerDelegate, SideMenuDelegate{
    func onSettings() {
    
    }

    func onHome() {
        
    }

    func onProfile() {
        
    }

    func onMessage() {
        
    }

    func onCalendar() {
        
    }

    func onIntention() {
        
    }

    func onBack() {
        
    }
    var index : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 179/255, green: 33/255, blue: 33/255, alpha: 1)
        
        let navController = storyboard!.instantiateViewController(withIdentifier: "leftmenu") as! UISideMenuNavigationController
        SideMenuManager.menuLeftNavigationController = navController
        
        SideMenuManager.menuAddPanGestureToPresent(toView: (self.navigationController?.navigationBar)!)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: (self.navigationController?.view)!)
        
        SideMenuManager.menuShadowOpacity = 0.3
        SideMenuManager.menuAnimationFadeStrength = 0
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuBlurEffectStyle = nil
        
        SideMenuManager.menuFadeStatusBar = false
        
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func NavBarShow() {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = ""
        
        let attrs = [NSForegroundColorAttributeName : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attrs
        navigationController?.navigationBar.tintColor = UIColor.white
        
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if (item.title == "Home"){
            self.index = 0
        }
        if (item.title == "Profile"){
            self.index = 1
        }
        if (item.title == "New Intention"){
            //self.selectedIndex =  2 : NONE
        }
        if (item.title == "Calendar"){
            self.index = 3
        }
        if (item.title == "Chat"){
            self.index = 4
        }
        
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        if (tabBarController.selectedIndex == 2){
            tabBarController.selectedIndex = self.index
            self.performSegue(withIdentifier: "newintention", sender: nil)
            self.NavBarShow()
        }
        
    }
    

}
