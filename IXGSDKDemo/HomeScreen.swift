//
//  HomeScreen.swift
//  IXGSDKDemo
//
//  Created by Aaron Johnson on 12/15/23.
//

import Foundation
import UIKit
import AVFoundation
import AiphoneIntercomCorePkg

final class HomeScreen: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var mobileAppStationsList: [MobileAppStation] = []
    
    lazy var registrationManager: RegistrationManager = {//IXG SDK registration manager
        let session = URLSession.shared//custom network session
        session.configuration.timeoutIntervalForRequest = 5//limits perameter for testing
        return RegistrationManager(urlSession: session)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video)//checks if device has camera capable of video, saves it if so
        else {
            print("Missing video device")
            return
        }
        
        let videoInput: AVCaptureDeviceInput//camera
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)//try activating camera
        } catch {
            print("couldnt create video input")
            return
        }
        if(captureSession.canAddInput(videoInput)) {//if camera is available to us
            captureSession.addInput(videoInput)//turn it on
        }
        else{
            //TODO
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if(captureSession.canAddOutput(metadataOutput)){
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]//filter to only care about QR codes
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)//setting up user preview of camera
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async{ self.captureSession.startRunning() }//start the camera
    }
    
    //If metadata object (QR code) was detected in camera
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()//stop camera so we can process what was captured
        
        if let metadataObject = metadataObjects.first {//if there was indeed valid metadata
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }//get the data from QR
            guard let stringValue = readableObject.stringValue else { return }//and read it as a string
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))//vibrate phone to let user know we have something
            handleQR(stringValue)//and process string with API
        }
    }
    
    fileprivate func handleQR(_ qrString: String) {
        print(qrString)
        Task {
            let qrResponse = await registrationManager.send(qrCode: qrString)//api response after we send string from QR
            
            switch qrResponse {
            case .success(let stationList)://if QR was valid and returned a list of slots
                mobileAppStationsList = stationList//save slots for next screen
                performSegue(withIdentifier: Segue.appSlots.rawValue, sender: self)//and transition
                
            case .failure(let error)://if QR was not valid and returned an alert
                let alertVC = UIAlertController(title: "Registration Error!", message: error.localizedDescription, preferredStyle: .alert)//dispkay alert
                let okayAction = UIAlertAction(title: "OK", style: .default) { _ in
                    DispatchQueue.global(qos: .background).async{ self.resetCaptureSession() }//and reset camera once users select "OK" on error
                }
                alertVC.addAction(okayAction)
                present(alertVC, animated: true)
            }
        }
    }
    
    nonisolated fileprivate func resetCaptureSession(){// simply stoping and starting camera to let users try scanning again
        captureSession.stopRunning()
        captureSession.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SlotSelectorTableViewController else { return }
        vc.mobileAppStationsList = mobileAppStationsList//sets the list of slots for the user to be able to select from
    }
}

extension HomeScreen{
    enum Segue: String{
        case appSlots = "displayAppSlots" //screen with list of slots for user to select
    }
}
