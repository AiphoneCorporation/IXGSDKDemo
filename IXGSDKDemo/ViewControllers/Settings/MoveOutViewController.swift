//
//  MoveOutViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 2/7/24.
//

import UIKit
import AiphoneIntercomCorePkg

class MoveOutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func moveButton(_ sender: Any) {
        let alert = UIAlertController(title: "Move Out", message: "This will unregister you from the current unit and reset the app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            Task{
                let result = await RegistrationManager(session: .shared).deregister()
                
                switch result {
                case .success(_):
                    self.restartApplication()
                case .failure(let error):
                    print(error)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func restartApplication () {
        // TODO: clean up the window heirarchy
        performSegue(withIdentifier: Segue.deregistered.rawValue, sender: self)
    }
}

extension MoveOutViewController {
    enum Segue: String {
        case deregistered = "appDeregisteredSegue"
    }
}
