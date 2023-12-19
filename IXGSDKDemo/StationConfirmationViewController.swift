//
//  StationConfirmationViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/19/23.
//

import UIKit
import AiphoneIntercomCorePkg

class StationConfirmationViewController: UIViewController {
    var selectedSlot: AppSlot!
    @IBOutlet weak var stationNameTextField: UITextField!
    @IBOutlet weak var stationNumberLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        stationNumberLabel.text = String(selectedSlot.stationNumber)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func confirmationButtonTapped(_ sender: Any) {
    }
    
}
