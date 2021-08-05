//
//  AddViewController.swift
//  Calorie Tracker
//
//  Created by Henry Doan on 7/30/21.
//

import UIKit

protocol AddProtocol {
    func setAddedValues(addName: String, addCal: Int, addIntake: Bool)
}

class AddViewController: UIViewController {
    
    // add form inputs
    @IBOutlet weak var addNameTxtBx: UITextField!
    @IBOutlet weak var addCallTxtBx: UITextField!
    @IBOutlet weak var intakeSwitch: UISwitch!
    
    var delegate:AddProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add";
        
        let save = UIBarButtonItem(barButtonSystemItem: .save,
        target: self,
        action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
    }
    
    @objc func saveItem() {
        let addedName = addNameTxtBx.text!
        let addedCal = Int(addCallTxtBx.text!) ?? 0
        let addedIntake = intakeSwitch.isOn

        delegate?.setAddedValues(addName: addedName, addCal: addedCal, addIntake: addedIntake)
        
        self.navigationController?.popViewController(animated: true)
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
