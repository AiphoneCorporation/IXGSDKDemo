//
//  RootViewController.swift
//  IXGSDKDemo
//
//  Created by Michael Sweeney on 2/12/24.
//

import UIKit
import AiphoneIntercomCorePkg

class RootViewController: UIViewController {

    let registrationManager = RegistrationManager(session: URLSession.shared)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            let result = await registrationManager.getStatus()
            switch result {
            case .success(let status):
                switch status {
                case .registered:
                    performSegue(withIdentifier: Segue.home.rawValue, sender: self)
                case .deregistered:
                    performSegue(withIdentifier: Segue.qrScanner.rawValue, sender: self)
                }
            case .failure(let error):
                print(error)
                assertionFailure("Found an error: see console for details")
            }
        }
    }
}

extension RootViewController {
    enum Segue: String {
        case qrScanner = "qrScanSegue"
        case home = "homeSegue"
    }
}
