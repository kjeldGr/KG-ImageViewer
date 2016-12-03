//
//  FilterViewController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import DrawerController

enum Setting: String {
    case showedIntro = "ShowedIntro"
    case showNSFW = "ShowNSFWImages"
    case saveHighRes = "SaveHighResImages"
    case protectWithPin = "ProtectWithPin"
    case useTouchID = "UseTouchID"
}

extension Setting {
    
    func setTrue(_ isTrue: Bool = true) {
        UserDefaults.standard.set(isTrue, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func isTrue() -> Bool {
        return UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
}

class FilterViewController: UIViewController {

    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var cacheSwitch: UISwitch!
    @IBOutlet weak var pinSwitch: UISwitch!
    @IBOutlet weak var touchIDSwitch: UISwitch!
    @IBOutlet weak var touchIDLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nsfwSwitch.setOn(Setting.showNSFW.isTrue(), animated: false)
        cacheSwitch.setOn(Setting.saveHighRes.isTrue(), animated: false)
        pinSwitch.setOn(Setting.protectWithPin.isTrue(), animated: false)
        touchIDSwitch.setOn(Setting.useTouchID.isTrue(), animated: false)
        touchIDSwitch.isHidden = !Setting.useTouchID.isTrue()
        touchIDLabel.isHidden = !Setting.useTouchID.isTrue()
        
        statusBarView.layer.shadowColor = UIColor.black.cgColor
        statusBarView.layer.shadowOffset = CGSize(width: 3.0, height: 6.0)
        statusBarView.layer.shadowOpacity = 0.25
    }

    @IBAction func toggleNsfwSwitch(_ sender: AnyObject) {
        Setting.showNSFW.setTrue(nsfwSwitch.isOn)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Setting.showNSFW.rawValue), object: nil)
    }
    
    @IBAction func toggleCacheSwitch(_ sender: AnyObject) {
        if !cacheSwitch.isOn {
            CacheData.sharedInstance.imageCache.removeAllObjects()
        }
        Setting.saveHighRes.setTrue(cacheSwitch.isOn)
    }
    
    @IBAction func togglePinSwitch(_ sender: AnyObject) {
        touchIDLabel.isHidden = !pinSwitch.isOn
        touchIDSwitch.isHidden = !pinSwitch.isOn
        
    }
    
    @IBAction func toggleTouchIDSwitch(_ sender: AnyObject) {
        Setting.useTouchID.setTrue(touchIDSwitch.isOn)
    }
    
    @IBAction func introButtonPressed(_ sender: AnyObject) {
        evo_drawerController?.setCenterViewController(
            storyboard!.viewController(withViewType: .intro), withCloseAnimation: true, completion: nil
        )
    }
    
}
