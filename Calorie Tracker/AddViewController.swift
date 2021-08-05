//
//  AddViewController.swift
//  Calorie Tracker
//
//  Created by Henry Doan on 7/30/21.
//

import UIKit

class AddViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add";
        
        let save = UIBarButtonItem(barButtonSystemItem: .save,
        target: self,
        action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
    }
    
    @objc func saveItem() {
        //... //set up and call the function specified by the
        //protocol
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
