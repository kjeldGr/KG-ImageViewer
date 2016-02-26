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

class FilterViewController: UIViewController {

    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var cacheSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nsfwSwitch.setOn(NSUserDefaults.standardUserDefaults().boolForKey(Setting.ShowNSFW.rawValue), animated: false)
        cacheSwitch.setOn(NSUserDefaults.standardUserDefaults().boolForKey(Setting.SaveHighRes.rawValue), animated: false)
    }

    @IBAction func toggleNsfwSwitch(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(nsfwSwitch.on, forKey: Setting.ShowNSFW.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(Setting.ShowNSFW.rawValue, object: nil)
    }
    
    @IBAction func toggleCacheSwitch(sender: AnyObject) {
        if !cacheSwitch.on {
            CacheData.sharedInstance.imageCache.removeAllObjects()
        }
        NSUserDefaults.standardUserDefaults().setBool(cacheSwitch.on, forKey: Setting.SaveHighRes.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func introButtonPressed(sender: AnyObject) {
        evo_drawerController?.setCenterViewController(
            storyboard!.instantiateViewControllerWithIdentifier("IntroView"), withCloseAnimation: true, completion: nil
        )
    }
    
}
