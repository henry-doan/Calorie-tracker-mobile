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
    
    /* random outtake calorie dictionary from https://www.health.harvard.edu/diet-and-weight-loss/calories-burned-in-30-minutes-of-leisure-and-routine-activities
        take the workouts and the calories from activites
     */
    var randOuttakes = [
        Calorie(name: "General Weight Lifting", cals: 90, intake: false),
        Calorie(name: "Water Aerobics", cals: 120, intake: false),
        Calorie(name: "Stretching", cals: 120, intake: false),
        Calorie(name: "Calisthenics", cals: 135, intake: false),
        Calorie(name: "Stair Machine", cals: 180, intake: false),
        Calorie(name: "Bicycling Machine", cals: 210, intake: false),
        Calorie(name: "Rowing Machine", cals: 210, intake: false),
        Calorie(name: "Circuit Training", cals: 240, intake: false),
        Calorie(name: "Elliptical Machine", cals: 270, intake: false),
        Calorie(name: "Tennis", cals: 240, intake: false)
    ]
    
    
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

    @IBAction func randOutake(_ sender: Any) {
        let randomOuttake = randOuttakes.randomElement()!
        addNameTxtBx.text = randomOuttake.name
        addCallTxtBx.text = "\(randomOuttake.cals)"
        intakeSwitch.isOn = randomOuttake.intake
    }
    
    @IBAction func randIntake(_ sender: Any) {
        var randIntakeName = ""
        var randIntakeCal = ""
        var url : String = "https://api.edamam.com/api/recipes/v2?type=public&q=chicken&app_id=516a82bb&app_key=602802aa8647f8dbdde83d855eb9aea6&random=true"
        URLSession.shared.dataTask(with: NSURL(string: url) as! URL) { data, response, error in
            // Handle result
            let response = String (data: data!, encoding: String.Encoding.utf8)
//        print("response is \(response)")
            do {
                let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)

//              print("get res \(getResponse)")
                                
                let recipesDict = getResponse as! NSDictionary

                let recipesArr = recipesDict["hits"] as! NSArray
//                print(recipesArr[0])
                let recipe = recipesArr[0] as! NSDictionary
//                print("--------------------------------")
                let randFood = recipe["recipe"] as! NSDictionary
                let randRecipeCal = randFood["calories"] as! NSNumber
                let randRecipeName = randFood["label"]! as! NSString
//                print(randFood["calories"]!)
                print(randFood["label"]!)
                print(randRecipeCal.intValue)
                randIntakeName = randRecipeName as String
                randIntakeCal = "\(randRecipeCal.intValue)"
                DispatchQueue.main.async {
                    self.addNameTxtBx.text = randIntakeName
                    self.addCallTxtBx.text = randIntakeCal
                    self.intakeSwitch.isOn = true
                }

            } catch {
                print("error serializing JSON: \(error)")
            }
        }.resume()
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
