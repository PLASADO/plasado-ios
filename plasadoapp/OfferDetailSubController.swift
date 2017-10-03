//
//  OfferDetailSubController.swift
//  plasado
//
//  Created by a on 8/7/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit

import EVTopTabBar
class OfferDetailSubController: UIViewController ,EVTabBar ,EVTabBarDelegate{
    var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var topTabBar: EVPageViewTopTabBar? {
        didSet {
            topTabBar?.fontColors = (selectedColor: UIColor.black, unselectedColor: UIColor.black)
            topTabBar?.rightButtonText = "Chat"
            topTabBar?.leftButtonText = "Details"
            //topTabBar?.labelFont = UIFont(name: "Arial", size: 20)!
            topTabBar?.indicatorViewColor = UIColor.init(red: 179/255, green: 33/255, blue: 33/255, alpha: 1)
            //topTabBar?.backgroundColor = UIColor.init(red: 241, green: 241, blue: 241, alpha: 1)
            topTabBar?.delegate = self
        }
    }
    var object : Offer!
    var subviewControllers: [UIViewController] = []
    var shadowView = UIImageView(image: UIImage(named: "filter-background-image"))
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topTabBar = EVPageViewTopTabBar(for: .two)
        let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "OfferDetailContentController") as! OfferDetailContentController//OfferDetailContentController()
        firstVC.object = object;
        let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "OfferDetailContentController")as! OfferDetailContentController
        secondVC.object = object
        subviewControllers = [firstVC, secondVC]
        setupPageView()
        setupConstraints()
        
        print(object)
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
    func willSelectViewControllerAtIndex(_ index: Int, direction: UIPageViewControllerNavigationDirection) {
        if index > subviewControllers.count {
            pageController.setViewControllers([subviewControllers[subviewControllers.count - 1]], direction: direction, animated: true, completion: nil)
        } else {
            pageController.setViewControllers([subviewControllers[index]], direction: direction, animated: true, completion: nil)
        }
    }
}
