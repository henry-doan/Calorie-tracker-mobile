//
//  ViewController.swift
//  Calorie Tracker
//
//  Created by Henry Doan on 7/29/21.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddProtocol, EditProtocol {
    
    // array to store calories items
    var calsArr: [Calorie] = []
    
    // int total calorie count
    var totalCal = 0
    
    // index of the item being edited
    var calItemBeingEdited: Int!
    
    // view items
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CalTotalLbl: UILabel!
    
    // db pointer
    var db: OpaquePointer?
    
    // function of the initial load
    override func viewDidLoad() {
        super.viewDidLoad()
        // set title
        self.title = "Calorie Tracker";
        
        // notifcation to save to the db
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
        selector: #selector(saveToDatabase(_:)),
        name: UIApplication.willResignActiveNotification,
        object: nil)
              
        // create initial db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("CalorieTracker.sqlite")
                
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
            
        // create table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Calories (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, cals INTEGER, intake INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
             
        // load items to the table
        loadItemList()
    }
    
    // load items from the db to the view
    func loadItemList(){
        // grab vals from db
        let queryString = "SELECT * FROM Calories"
         
        var stmt:OpaquePointer?
         
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return
        }
         
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let dbname = String(cString: sqlite3_column_text(stmt, 1))
            let dbcals = Int(sqlite3_column_int(stmt, 2))
            let dbintake = Int(sqlite3_column_int(stmt, 3))
            var dbBoolIntake = true
            if (dbintake == 0) {
                dbBoolIntake = false
            }
            
            // add to cal arr
            calsArr.append(Calorie(name: dbname, cals: dbcals, intake: dbBoolIntake))
        }
        
        // calculate running calorie total
        calcTotal()
    }
    
    // function to save items to database
    @objc func saveToDatabase(_ notification:Notification) {

        // delete all items in the db
        let deleteQuery = "DELETE FROM Calories"
        if sqlite3_exec(db, "DELETE FROM Calories", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error Deleting all items: \(errmsg)")
        }

        var delstmt:OpaquePointer?
        if sqlite3_prepare(db, deleteQuery, -1, &delstmt, nil) != SQLITE_OK {
            print("error preparing delete")
        }

        if sqlite3_finalize(delstmt) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }

        // insert to db
        for cal in calsArr {
            var stmt: OpaquePointer?
            let name = cal.name
            let cals = cal.cals
            let intake = cal.intake
            let intIntake = (intake) ? 1 : 0
            let queryString = "INSERT INTO Calories (name, cals, intake) VALUES (?,?,?)"

            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }

            if sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }

            if sqlite3_bind_int(stmt, 2, (String(cals) as NSString).intValue)  != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding cals: \(errmsg)")
                return
            }
            
            if sqlite3_bind_int(stmt, 3, (String(intIntake) as NSString).intValue) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding intake: \(errmsg)")
                return
            }


            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting cal: \(errmsg)")
                return
            }
        }
        
        // update table view
        tableView.reloadData()
        
        // recalculate calorie total
        calcTotal()
        //close db
//        sqlite3_close(db)
    }
    
    // what to do to prepare for segue to other views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addSegue") {
            let view = segue.destination as! AddViewController
            view.delegate = self
        }
                
        if (segue.identifier == "editSegue") {
            calItemBeingEdited = tableView.indexPathForSelectedRow?.row

            // Instantiate editViewController
            let editViewController = segue.destination as! EditViewController
            
            // set edit item data
            editViewController.editName = calsArr[calItemBeingEdited].name
            editViewController.editCal = calsArr[calItemBeingEdited].cals
            editViewController.editIntake = calsArr[calItemBeingEdited].intake
                    
                    
            let view = segue.destination as! EditViewController
            view.delegate = self
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
            
            self.calcTotal()

            actionPerformed(true)
        }
            
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // function to add the calorie item
    func setAddedValues(addName: String, addCal: Int, addIntake: Bool) {
        // add new item
        let newItem = Calorie(name: addName, cals: addCal, intake: addIntake)
        calsArr.append(newItem)
        
        // reload values
        self.tableView.reloadData()
        
        // recalulate calorie total
        calcTotal()
    }
    
    // function to edit a calorie item
    func setEditedValues(editName: String, editCal: Int, editIntake: Bool) {
        // change item edited to new values
        calsArr[calItemBeingEdited].name = editName
        calsArr[calItemBeingEdited].cals = editCal
        calsArr[calItemBeingEdited].intake = editIntake
                
        // reload values
        self.tableView.reloadData()
        
        // recalulate calorie total
        calcTotal()
    }
    
    // function to calulate the calorie total
    func calcTotal() {
        // set initially to 0
        totalCal = 0
        
        // for each item in cal array
        for cal in calsArr {
            if (cal.intake) {
                // add the intake
                totalCal += cal.cals
            } else {
                // subtract outake
                totalCal -= cal.cals
            }
        }
        
        // display running total
        CalTotalLbl.text = "\(totalCal)"
        
        // change color base on recommended calorie intake
        if (totalCal < 2000) {
            // too low
            CalTotalLbl.textColor = UIColor.yellow
        } else if (totalCal >= 2000 && totalCal <= 2500) {
            // just right
            CalTotalLbl.textColor = UIColor.green
        } else if (totalCal > 2500) {
            // too much
            CalTotalLbl.textColor = UIColor.red
        }
    }
    
    // event handler for reseting the app to a initial state
    @IBAction func resetApp(_ sender: Any) {
        // reset running calorie total
        totalCal = 0
        CalTotalLbl.text = "\(totalCal)"
        
        // clear our calsArr
        calsArr = []
        
        // delete all items in the db
        let deleteQuery = "DELETE FROM Calories"
        if sqlite3_exec(db, "DELETE FROM Calories", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error Deleting all items: \(errmsg)")
        }

        var delstmt:OpaquePointer?
        if sqlite3_prepare(db, deleteQuery, -1, &delstmt, nil) != SQLITE_OK {
            print("error preparing delete")
        }

        if sqlite3_finalize(delstmt) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        // refresh the view
        tableView.reloadData()
    }
}
