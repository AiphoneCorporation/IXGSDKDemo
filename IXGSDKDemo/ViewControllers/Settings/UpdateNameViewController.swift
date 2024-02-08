//
//  UpdateNameViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 2/7/24.
//

import UIKit
import AiphoneIntercomCorePkg

class UpdateNameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    var newName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//user tapped Done
        textField.resignFirstResponder()//accept and close keyboard (calls textFieldDidEndEditing)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            updateButton.isEnabled = false
            return
        }//if value is null, do nothing
        
        updateButton.isEnabled = true
        newName = text// update with new name
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        Task{
            let result = await RegistrationManager(session: .shared).rename(name: newName)
            
            switch result {
                
            case .success():
                let alert = UIAlertController(title: "Name Updated", message: "Your name has been updated to \(newName!)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
