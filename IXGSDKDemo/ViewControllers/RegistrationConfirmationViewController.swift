//
//  StationConfirmationViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/19/23.
//

import UIKit
import AiphoneIntercomCorePkg

class RegistrationConfirmationViewController: UIViewController, UITextFieldDelegate {
    var registrationManager: RegistrationManager!
    @IBOutlet weak var stationNameTextField: UITextField!
    var stations = [IXGStation]()
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        stationNameTextField.delegate = self
        
        stationNameTextField.text = "Enter name"//update text input default text to default name
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//user tapped Done
        textField.resignFirstResponder()//accept and close keyboard (calls textFieldDidEndEditing)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }//if value is null, do nothing
        
        name = text// update with new name
    }
    
    @IBAction func confirmationButtonTapped(_ sender: Any) {
        Task {
            let result = await registrationManager.register(name: name)
            switch result {
            case .success:
                performSegue(withIdentifier: Segue.registrationConfirmed.rawValue, sender: self)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension RegistrationConfirmationViewController{
    enum Segue: String{
        case registrationConfirmed = "registrationFinished"
    }
}
