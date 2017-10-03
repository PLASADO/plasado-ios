//
//  TutorialController.swift
//  plasado
//
//  Created by Emperor on 8/2/17.
//  Copyright © 2017 Emperor. All rights reserved.
//

import UIKit
class TutorialController: UIViewController , UIScrollViewDelegate{

    let titles : [String] = ["Give us your key datas","Let us do the work","Choose and save money"]
    let texts : [String] = ["We want to help you plan better, save money and do more of the things you intent do. When you think of a day your free or need to do something, let us know!",
                            "Our team of concierge will work with our partners to provide you options to choose from to fulfill your intension",
                            "Review offers as they come, chat with partners and fulfill your intention on the spot"]
    let textColor = UIColor.init(red: 44/255, green: 45/255, blue: 45/255, alpha: 1)
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: FXPageControl!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBAction func pageControlAction(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        
        let page1 = Bundle.main.loadNibNamed("TutorView1", owner: self, options: nil)?.last as! UIView
        let page2 = Bundle.main.loadNibNamed("TutorView2", owner: self, options: nil)?.last as! UIView
        let page3 = Bundle.main.loadNibNamed("TutorView3", owner: self, options: nil)?.last as! UIView
        page1.frame = self.view.layer.frame
        page2.frame = CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight)
        page3.frame = CGRect(x: scrollViewWidth * 2, y: 0, width: scrollViewWidth, height: scrollViewHeight)
        //let page1 = TutorPage1(frame: self.view.layer.frame)
        //let page2 = TutorPage2(frame: CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        //let page3 = TutorPage3(frame: CGRect(x: scrollViewWidth * 2, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        
        scrollView.addSubview(page1)
        scrollView.addSubview(page2)
        scrollView.addSubview(page3)
    

        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 3, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        
        self.pageControl.numberOfPages = 3;
        self.pageControl.defersCurrentPageDisplay = true;
        self.pageControl.currentPage = 0
        self.pageControl.selectedDotColor = UIColor(red: 179/255, green: 39/255, blue: 33/255, alpha: 1)
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        // Change the text accordingly
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onNext(_ sender: Any) {
        let scrollViewWidth:Int = Int(self.scrollView.frame.width)
        let scrollViewHeight:Int = Int(self.scrollView.frame.height)
        
        if (Int(scrollView.contentOffset.x) < scrollViewWidth * 2){
            self.scrollView.scrollRectToVisible(CGRect(x: scrollViewWidth + Int(scrollView.contentOffset.x) , y: 0, width: scrollViewWidth, height: scrollViewHeight), animated: true)
        }
        else{
            onSkip(Any)
        }
        

    }

    @IBAction func onSkip(_ sender: Any) {
        self.performSegue(withIdentifier: "tellusmore", sender: nil)
    }

}
