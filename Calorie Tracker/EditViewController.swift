//
//  EditViewController.swift
//  Calorie Tracker
//
//  Created by Henry Doan on 7/30/21.
//

import UIKit

protocol EditProtocol {
    func setEditedValues(editName: String, editCal: Int, editIntake: Bool)
}

class EditViewController: UIViewController {

    @IBOutlet weak var editNameTxtBx: UITextField!
    @IBOutlet weak var editCalTxtBx: UITextField!
    @IBOutlet weak var editIntakeSwitch: UISwitch!
    
    // vars to hold edit info
    var editName : String?
    var editCal : Int?
    var editIntake : Bool?
    
    // delegate for edit protocol
    var delegate:EditProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit";
        
        let save = UIBarButtonItem(barButtonSystemItem: .save,
        target: self,
        action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
    }
    
    @objc func saveItem() {
        // set up and call the function specified by the protocol
        self.navigationController?.popViewController(animated: true)
                
        // save items to vars
        let editedName = editNameTxtBx.text!
        let editedCal = Int(editCalTxtBx.text!) ?? 0
        let editIntake = editIntakeSwitch.isOn
                
        delegate?.setEditedValues(editName: editedName, editCal: editedCal, editIntake: editIntake)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        // set inputs to edit value
        editNameTxtBx.text = editName!
        editCalTxtBx.text = "\(editCal!)"
        editIntakeSwitch.isOn = editIntake ?? true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
