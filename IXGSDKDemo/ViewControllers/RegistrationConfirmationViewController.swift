//
//  StationConfirmationViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/19/23.
//

import UIKit
import AiphoneIntercomCorePkg

class RegistrationConfirmationViewController: UIViewController, UITextFieldDelegate {
    var selectedSlot: IXGMobileAppStation!
    var registrationManager: RegistrationManager!
    @IBOutlet weak var stationNameTextField: UITextField!
    @IBOutlet weak var stationNumberLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        stationNameTextField.delegate = self
        
        stationNumberLabel.text = String(selectedSlot.number)//Update number to number of selected station
        stationNameTextField.text = String(selectedSlot.number)//Update text input default text to number of selected station
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//user tapped Done
        textField.resignFirstResponder()//accept and close keyboard (calls textFieldDidEndEditing)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }//if value is null, do nothing
        selectedSlot.name = text//else update text to what is in field
    }
    
    @IBAction func confirmationButtonTapped(_ sender: Any) {
        Task {
            let result = await registrationManager.register(appSlot: selectedSlot)
            switch result {
            case .success(let message):
                print(message)
                performSegue(withIdentifier: Segue.registrationConfirmed.rawValue, sender: self)//and move on to said screen
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension RegistrationConfirmationViewController{
    enum Segue: String{
        case registrationConfirmed = "registrationFinished"
    }
}
