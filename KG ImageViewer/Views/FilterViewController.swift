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
    case ShowedIntro = "ShowedIntro"
    case ShowNSFW = "ShowNSFWImages"
    case SaveHighRes = "SaveHighResImages"
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

    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var cacheSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nsfwSwitch.setOn(Setting.ShowNSFW.isTrue(), animated: false)
        cacheSwitch.setOn(Setting.SaveHighRes.isTrue(), animated: false)
    }

    @IBAction func toggleNsfwSwitch(_ sender: AnyObject) {
        Setting.ShowNSFW.setTrue(nsfwSwitch.isOn)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Setting.ShowNSFW.rawValue), object: nil)
    }
    
    @IBAction func toggleCacheSwitch(_ sender: AnyObject) {
        if !cacheSwitch.isOn {
            CacheData.sharedInstance.imageCache.removeAllObjects()
        }
        Setting.SaveHighRes.setTrue(cacheSwitch.isOn)
    }
    
    @IBAction func introButtonPressed(_ sender: AnyObject) {
        evo_drawerController?.setCenterViewController(
            storyboard!.viewController(withViewType: .Intro), withCloseAnimation: true, completion: nil
        )
    }
    
}
