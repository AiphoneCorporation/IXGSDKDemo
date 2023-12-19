//
//  StationConfirmationViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/19/23.
//

import UIKit
import AiphoneIntercomCorePkg

class StationConfirmationViewController: UIViewController, UITextFieldDelegate {
    var selectedSlot: MobileAppStation!
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
        //api.register(selectedSlot)
        //transition to next screen
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
