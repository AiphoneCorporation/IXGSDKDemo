//
//  CallViewController.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 1/23/24.
//

import UIKit
import CallKit
import PushKit
import AiphoneIntercomCorePkg

class CallViewController: UIViewController, CXProviderDelegate {
    let callController = CXCallController()
    var provider: CXProvider!
    var station: IXGStation!
    var callType: String!//TODO: get enum from sdk

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("I will \(callType!) station \(station!.name)")
        
        let config = CallKit.CXProviderConfiguration()
        provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeOutgoing("call", callFormat: "video")//TODO: replace with call Type (call/monitor) and call format (video/audio)
    }
    
    private func makeOutgoing(_ calltype: String, callFormat: String) {
        let uuid = UUID()
        let recipient = CXHandle(type: .generic, value: station.name)
        let startCallAction = CXStartCallAction(call: uuid, handle: recipient)
        let transaction = CXTransaction(action: startCallAction)
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
                //TODO: call sdk outgoing function
            }
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    func providerDidReset(_ provider: CXProvider) {
        //TODO: handle this
    }
}
