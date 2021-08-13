//
//  EditViewController.swift
//  Calorie Tracker
//
//  Created by Henry Doan on 7/30/21.
//

import UIKit

// edit protocol to edit a cal item
protocol EditProtocol {
    func setEditedValues(editName: String, editCal: Int, editIntake: Bool)
}

class EditViewController: UIViewController {
    // form items
    @IBOutlet weak var editNameTxtBx: UITextField!
    @IBOutlet weak var editCalTxtBx: UITextField!
    @IBOutlet weak var editIntakeSwitch: UISwitch!
    
    // vars to hold edit info
    var editName : String?
    var editCal : Int?
    var editIntake : Bool?
    
    // delegate for edit protocol
    var delegate:EditProtocol?
    
    // function to run when the form is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title
        self.title = "Edit";
        
        // have a save button
        let save = UIBarButtonItem(barButtonSystemItem: .save,
        target: self,
        action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
    }
    
    // function that triggers a save on the form
    @objc func saveItem() {
        // set up and call the function specified by the protocol
        self.navigationController?.popViewController(animated: true)
                
        // save items to vars
        let editedName = editNameTxtBx.text!
        let editedCal = Int(editCalTxtBx.text!) ?? 0
        let editIntake = editIntakeSwitch.isOn
             
        // call the delegate to edit values
        delegate?.setEditedValues(editName: editedName, editCal: editedCal, editIntake: editIntake)
    }
    
    // function to grab cal item data into the edit form
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        // set inputs to edit value
        editNameTxtBx.text = editName!
        editCalTxtBx.text = "\(editCal!)"
        editIntakeSwitch.isOn = editIntake ?? true
    }
}
