//
//  AuthenticationViewController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 13-10-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: KGViewController {

    let authenticationContext = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticate()
        let textFields: [UITextField] = view.subviewsOfType()
        for textField in textFields {
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        }
    }
    
    func authenticate() {
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return }
        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "test", reply: { [unowned self] (success: Bool, error: Error?) -> Void in
            if (error != nil) {
                self.authenticationFailedWithError(error: error as NSError!)
            } else {
                self.authenticationSucceeded()
            }
        })
    }
    
    func authenticationFailedWithError(error: NSError) {
        switch LAError(_nsError: error).code {
        case .authenticationFailed:
            // Show error
            break
        default:
            break
        }
    }
    
    func authenticationSucceeded() {
        DispatchQueue.main.async {
            let textFields: [UITextField] = self.view.subviewsOfType()
            for textField in textFields {
                textField.text = "1"
            }
        }
    }

    @IBAction func didChangeText(_ sender: AnyObject) {
        
//        perform(#selector(AuthenticationViewController.dismiss(animated:completion:)), with: [true, nil], afterDelay: 0.3)
    }
    
}

extension AuthenticationViewController: UITextFieldDelegate {
    
    
}
