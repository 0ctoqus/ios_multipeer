//
//  ViewController.swift
//  Perami
//
//  Created by Octave on 12/4/18.
//  Copyright © 2018 Octave. All rights reserved.
//

import UIKit
import MultiPeer

enum DataType: UInt32 {
    case message = 1
    case image = 2
}

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    // Image Picker
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MultiPeer.instance.delegate = self
        
        textField.delegate = self
        imagePicker.delegate = self
        
        MultiPeer.instance.initialize(serviceType: "peerami-service")
        MultiPeer.instance.autoConnect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        MultiPeer.instance.disconnect()
        
        super.viewWillDisappear(animated)
    }
    
    // Dismiss keyboard on tap
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func didPressLoadButton(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func didPressSendButton(_ sender: Any) {
        // Advertising/Browsing while sending data in MultiPeerConnectivity causes disconnects
        // see here: https://stackoverflow.com/questions/22720247/multipeer-connectivity-random-disconnects
        // Device will stop advertising/browsing until after MultiPeer has sent data
        MultiPeer.instance.stopSearching()
        
        defer {
            MultiPeer.instance.autoConnect()
        }
        
        //if let message = textField.text {
        //    print("sending", message)
        //    MultiPeer.instance.send(object: message, type: DataType.message.rawValue)
        //}
        
        
        if let image = UIImage(named: "goku") {
            guard let imageData = image.pngData() else { return }
            MultiPeer.instance.send(object: imageData, type: DataType.image.rawValue)
        }
    }
}


extension ViewController: MultiPeerDelegate {
    func multiPeer(didReceiveData data: Data, ofType type: UInt32) {
        switch type {
        case DataType.message.rawValue:
            guard let message = data.convert() as? String else { return }
            textField.text = message
            break

        case DataType.image.rawValue:
            guard let imageData = data.convert() as? Data else { return }
            imageView.image = UIImage(data: imageData)
            break
            
        default:
            print("Unknown type")
            break
        }
    }
    
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print("Connected devices changed: \(devices)")
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
