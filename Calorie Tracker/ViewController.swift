//
//  ViewController.swift
//  Calorie Tracker
//
//  Created by Henry Doan on 7/29/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // array to store calories items
    //var calsArr: [Calorie] = []
    var calsArr = [
        Calorie(name: "lunch", cals: 100, intake: true),
        Calorie(name: "Snack", cals: 60, intake: true),
        Calorie(name: "walk", cals: 40, intake: false),
    ]
    var totalCal = 0
    
    // index of the item being edited
    var calItemBeingEdited: Int!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CalTotalLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calorie Tracker";
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addSegue") {
            let view = segue.destination as! AddViewController
            //view.delegate = self
        }
                
        if (segue.identifier == "editSegue") {
            calItemBeingEdited = tableView.indexPathForSelectedRow?.row

            // Instantiate editViewController
            let editViewController = segue.destination as! EditViewController
            
            //editViewController. = calsArr[calItemBeingEdited].name
            //editViewController. = calsArr[calItemBeingEdited].cals
                    
                    
            let view = segue.destination as! EditViewController
            //view.delegate = self
        }
    }
    
    // function to defend number of rows of table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // initial number of rows
        var numOfRows = 0

        // count the number of items in the array
        numOfRows = calsArr.count
        
        // return number of rows
        return numOfRows
    }
    
    // create cells of table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create the initial cell with it be able to be brought back
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                
        // current selected cal item
        var currentItem: Calorie!

        currentItem = calsArr[indexPath.row]
                
        // fill the title
        cell.textLabel!.text = currentItem.name
          
        // set subtitle
        let calTxt = ""
        currentItem.intake ? calTxt + "+" : calTxt + "-"
        cell.detailTextLabel!.text = "\(calTxt) \(currentItem.cals)"
        cell.detailTextLabel!.textColor = currentItem.intake ? UIColor.green : UIColor.red
        
        // set accessory type
        cell.accessoryType = .disclosureIndicator
                
        return cell
    }
    
    // function to deselect row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    // swipe event to delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
                  (action:UIContextualAction, sourceView:UIView, actionPerformed:(Bool) -> Void) in
                  
            self.calsArr.remove(at: indexPath[1])
                
            tableView.reloadData()
            
            actionPerformed(true)
        }
            
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }


}

