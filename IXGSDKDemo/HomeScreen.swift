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
    var appSlots: [AppSlot] = []
    
    lazy var registrationManager: RegistrationManager = {
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 5
        return RegistrationManager(urlSession: session)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        else {
            print("Missing video device")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("couldnt create video input")
            return
        }
        if(captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        }
        else{
            //TODO
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if(captureSession.canAddOutput(metadataOutput)){
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async{ self.captureSession.startRunning() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            handleQR(stringValue)
        }
    }
    
    fileprivate func handleQR(_ qrString: String) {
        print(qrString)
        Task {
            let qrResponse = await registrationManager.send(qrCode: qrString)
            
            switch qrResponse {
            case .success(let slots):
                appSlots = slots
                performSegue(withIdentifier: Segue.appSlots.rawValue, sender: self)
                
            case .failure(let error):
                let alertVC = UIAlertController(title: "Registration Error!", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .default) { _ in
                    DispatchQueue.global(qos: .background).async{ self.resetCaptureSession() }
                }
                alertVC.addAction(okayAction)
                present(alertVC, animated: true)
            }
        }
    }
    
    nonisolated fileprivate func resetCaptureSession(){
        captureSession.stopRunning()
        captureSession.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SlotSelectorTableViewController else { return }
        vc.appSlots = appSlots
    }
}

extension HomeScreen{
    enum Segue: String{
        case appSlots = "displayAppSlots"
    }
}
