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
    var appInfo: IXGAppInfo!
    var stationName: String?
    @IBOutlet weak var stationNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        stationNameTextField.delegate = self
        
        stationNameTextField.text = appInfo.name//Update text input default text to default name
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//user tapped Done
        textField.resignFirstResponder()//accept and close keyboard (calls textFieldDidEndEditing)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }//if value is null, do nothing
        
        appInfo = IXGAppInfo(name: text, propertyId: appInfo.propertyId, qrCode: appInfo.qrCode, appSlotId: appInfo.appSlotId)//update appInfo with new name
    }
    
    @IBAction func confirmationButtonTapped(_ sender: Any) {
        Task {
            let result = await registrationManager.register(appInfo: appInfo)
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
