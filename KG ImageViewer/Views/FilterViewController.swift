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
    
    func setTrue(isTrue: Bool = true) {
        NSUserDefaults.standardUserDefaults().setBool(isTrue, forKey: self.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func isTrue() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(self.rawValue)
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

    @IBAction func toggleNsfwSwitch(sender: AnyObject) {
        Setting.ShowNSFW.setTrue(nsfwSwitch.on)
        NSNotificationCenter.defaultCenter().postNotificationName(Setting.ShowNSFW.rawValue, object: nil)
    }
    
    @IBAction func toggleCacheSwitch(sender: AnyObject) {
        if !cacheSwitch.on {
            CacheData.sharedInstance.imageCache.removeAllObjects()
        }
        Setting.SaveHighRes.setTrue(cacheSwitch.on)
    }
    
    @IBAction func introButtonPressed(sender: AnyObject) {
        evo_drawerController?.setCenterViewController(
            storyboard!.viewController(withViewType: .Intro), withCloseAnimation: true, completion: nil
        )
    }
    
}
