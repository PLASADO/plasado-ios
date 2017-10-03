//
//  CalendarOtherViewController.swift
//  
//
//  Created by a on 8/14/17.
//
//

import UIKit
import SwipeCellKit
import JBDatePicker
class CalendarOtherViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{


    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    
    
    @IBAction func onDoubleNext(_ sender: Any) {
    }

    @IBAction func onNext(_ sender: Any) {
        datePicker.loadNextView()
        year.text = "\(Calendar.current.component(Calendar.Component.year, from: datePicker.selectedDateView.date!))"
        
    }

    @IBAction func onPrevious(_ sender: Any) {
        datePicker.loadPreviousView()
        
        month.text = "\(DateFormatter().shortMonthSymbols[Calendar.current.component(Calendar.Component.month, from: datePicker.selectedDateView.date! - 1)])"
    }
    @IBAction func onDoublePrevious(_ sender: Any) {
    }
    
    
    @IBOutlet weak var datePicker: JBDatePickerView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive : Bool = false
    
    var data = ["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin","Seattle"]
    var filtered:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        datePicker.delegate = self
        
        year.text = "\(Calendar.current.component(Calendar.Component.year, from: datePicker.selectedDateView.date!))"
        month.text = "\(DateFormatter().shortMonthSymbols[Calendar.current.component(Calendar.Component.month, from: datePicker.selectedDateView.date!) - 1])"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getmonthTxt(number : Int) -> String{
        var result : String!
        switch number {
        case 0:
            result = "Jan"
        case 1:
            result = "Feb"
        case 2:
            result = "Mar"
        case 3:
            result = "Apr"
        case 4:
            result = "May"
        case 5:
            result = "Jun"
        case 6:
            result = "Jul"
        case 7:
            result = "Aug"
        case 8:
            result = "Sep"
        case 9:
            result = "Oct"
        case 10:
            result = "Nov"
        case 11:
            result = "Dec"
        default:
            result = "Jan"
        }
        return result
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
        filtered.removeAll()
        filtered = data.filter({
            $0.localizedCaseInsensitiveContains(searchText)
        })
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        return data.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTableViewCell") as! CalendarTableViewCell
        cell.delegate = self
        if(searchActive){
            //cell.textLabel?.text = filtered[indexPath.row]
            cell.intention_Title.text = filtered[indexPath.row]
        } else {
            //cell.textLabel?.text = data[indexPath.row];
            cell.intention_Title.text = data[indexPath.row];
        }
        
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "myintention", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = ""
    }
}

extension CalendarOtherViewController : SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
        var deleteAction : SwipeAction!
        deleteAction = SwipeAction(style: .destructive, title: "") { (deleteAction, indexPath) in
            
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.8165897727, green: 0.1942726374, blue: 0.2604972124, alpha: 1)
        deleteAction.image = UIImage(named: "cancel")
        
        var moreAction : SwipeAction!
        moreAction = SwipeAction(style: .destructive, title: "") { (moreAction, indexPath) in
            self.performSegue(withIdentifier: "myintention", sender: nil)
        }
        moreAction.backgroundColor = #colorLiteral(red: 0.7607252002, green: 0.7608175874, blue: 0.7606938481, alpha: 1)
        moreAction.image = UIImage(named: "more")
        return [deleteAction,moreAction]
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .border
        return options
    }
}
extension CalendarOtherViewController: JBDatePickerViewDelegate{
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        
    }
    var colorForWeekDaysViewBackground: UIColor{
        return UIColor.white
    }
    var colorForWeekDaysViewText : UIColor{
        return UIColor.black
    }
}
