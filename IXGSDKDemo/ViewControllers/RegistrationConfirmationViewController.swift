//
//  StationConfirmationViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/19/23.
//

import UIKit
import AiphoneIntercomCorePkg

class RegistrationConfirmationViewController: UIViewController, UITextFieldDelegate {
    var unitInfo: IXGUnitInfo!
    var selectedSlotIndex: Int!
    var selectedStation: IXGAppSlot!
    var registrationManager: RegistrationManager!
    var stationName: String?
    @IBOutlet weak var stationNameTextField: UITextField!
    @IBOutlet weak var stationNumberLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        stationNameTextField.delegate = self
        
        stationNumberLabel.text = selectedStation.number//Update number to number of selected station
        stationNameTextField.text = selectedStation.names.first//Update text input default text to number of selected station
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//user tapped Done
        textField.resignFirstResponder()//accept and close keyboard (calls textFieldDidEndEditing)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }//if value is null, do nothing
        
        selectedStation = IXGAppSlot(cliID: selectedStation.cliID, number: selectedStation.number, names: [text], registeredStatus: selectedStation.registeredStatus)//update selected station with new name
    }
    
    @IBAction func confirmationButtonTapped(_ sender: Any) {
        Task {
            let result = await registrationManager.register(appSlot: selectedStation)
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
