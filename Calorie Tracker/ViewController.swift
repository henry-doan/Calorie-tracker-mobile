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

    var totalCal = 0
    
    // index of the item being edited
    var calItemBeingEdited: Int!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CalTotalLbl: UILabel!
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calorie Tracker";
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
        selector: #selector(saveToDatabase(_:)),
        name: UIApplication.willResignActiveNotification,
        object: nil)
                
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("CalorieTracker.sqlite")
                
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
                
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Calories (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, cals INTEGER, intake INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
             
        loadItemList()
    }
    
    func loadItemList(){
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

            calsArr.append(Calorie(name: dbname, cals: dbcals, intake: dbBoolIntake))

        }

    }
    
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
        
        tableView.reloadData()
        
        //close db
//        sqlite3_close(db)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addSegue") {
            let view = segue.destination as! AddViewController
            view.delegate = self
        }
                
        if (segue.identifier == "editSegue") {
            calItemBeingEdited = tableView.indexPathForSelectedRow?.row

            // Instantiate editViewController
            let editViewController = segue.destination as! EditViewController
            
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
            
            actionPerformed(true)
        }
            
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // fucntion to add the calorie item
    func setAddedValues(addName: String, addCal: Int, addIntake: Bool) {
        // add new item
        let newItem = Calorie(name: addName, cals: addCal, intake: addIntake)
        calsArr.append(newItem)
        
        // reload values
        self.tableView.reloadData()
    }

    func setEditedValues(editName: String, editCal: Int, editIntake: Bool) {
        // change item edited to new values
        calsArr[calItemBeingEdited].name = editName
        calsArr[calItemBeingEdited].cals = editCal
        calsArr[calItemBeingEdited].intake = editIntake
                
        // reload values
        self.tableView.reloadData()
    }
}

