//
//  AddViewController.swift
//  Calorie Tracker
//
//  Created by Henry Doan on 7/30/21.
//

import UIKit

// add protocol to add a cal item
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
    
    // random food array of items to have in the api
    var randFoods = ["chicken", "beef", "pork", "fish", "bean", "veggie", "cake"]
    
    // add delegate
    var delegate:AddProtocol?
    
    // function to run when the form is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title
        self.title = "Add";
        
        // have a save button
        let save = UIBarButtonItem(barButtonSystemItem: .save,
        target: self,
        action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
    }
    
    // function that triggers a save on the form
    @objc func saveItem() {
        // grab form values
        let addedName = addNameTxtBx.text!
        let addedCal = Int(addCallTxtBx.text!) ?? 0
        let addedIntake = intakeSwitch.isOn

        // send to delegate to add to app
        delegate?.setAddedValues(addName: addedName, addCal: addedCal, addIntake: addedIntake)
        
        // navigate back to home controller
        self.navigationController?.popViewController(animated: true)
    }

    // event handler for a random outake
    @IBAction func randOutake(_ sender: Any) {
        // grab a random outtake
        let randomOuttake = randOuttakes.randomElement()!
        
        // fill out the form with ranom outtake
        addNameTxtBx.text = randomOuttake.name
        addCallTxtBx.text = "\(randomOuttake.cals)"
        intakeSwitch.isOn = randomOuttake.intake
    }
    
    // event handler for a random intake
    @IBAction func randIntake(_ sender: Any) {
        // initial values
        var randIntakeName = ""
        var randIntakeCal = ""
        
        // random food item to search
        let randFood = randFoods.randomElement()
        
        // url to the edamam api
        // TODO hide API Keys
        let url : String = "https://api.edamam.com/api/recipes/v2?type=public&q=" + randFood! + "&app_id=516a82bb&app_key=602802aa8647f8dbdde83d855eb9aea6&random=true"
        // hand api response
        URLSession.shared.dataTask(with: NSURL(string: url)! as URL) { data, response, error in
            // Handle result
           // let response = String (data: data!, encoding: String.Encoding.utf8)
           
            do {
                // parse the json
                let getResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                            
                // pares all the way to the correct wanted values
                let recipesDict = getResponse as! NSDictionary
                let recipesArr = recipesDict["hits"] as! NSArray
                let recipe = recipesArr[0] as! NSDictionary
                let randFood = recipe["recipe"] as! NSDictionary
                let randRecipeCal = randFood["calories"] as! NSNumber
                let randRecipeName = randFood["label"]! as! NSString
                
                // set vars to api values with right datatypes
                randIntakeName = randRecipeName as String
                randIntakeCal = "\(randRecipeCal.intValue)"
                
                // run during the main thread
                DispatchQueue.main.async {
                    // fill out form with values
                    self.addNameTxtBx.text = randIntakeName
                    self.addCallTxtBx.text = randIntakeCal
                    self.intakeSwitch.isOn = true
                }
                
            // if api has errors
            } catch {
                print("error serializing JSON: \(error)")
            }
        }.resume() // resume process
    }
}
