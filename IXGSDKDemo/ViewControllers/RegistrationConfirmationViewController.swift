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
        
        do{
            stationNameTextField.text = try IXGAppInfo.read().name//update text input default text to default name
        }
        catch{
            print(error.localizedDescription)
        }
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
