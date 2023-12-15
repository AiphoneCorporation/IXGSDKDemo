//
//  ViewController.swift
//  IXGSDKDemo
//
//  Created by Michael Sweeney on 12/15/23.
//

import UIKit
import AiphoneIntercomCorePkg

class ViewController: UIViewController {

    let api = IXGAPI()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let message = api.makeCall(station: 1)
        print(message)
    }
}

