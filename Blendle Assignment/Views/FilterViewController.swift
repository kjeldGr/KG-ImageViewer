//
//  FilterViewController.swift
//  Blendle Assignment
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit

enum Setting: String {
    case ShowNSFW = "ShowNSFWImages"
    case SaveHighRes = "SaveHighResImages"
}

class FilterViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var nsfwLabel: UILabel!
    @IBOutlet weak var cacheSwitch: UISwitch!
    @IBOutlet weak var cacheLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = NSLocalizedString("filter_text_title", comment: "")
        
        nsfwLabel.text = NSLocalizedString("filter_text_nsfw", comment: "")
        nsfwSwitch.setOn(NSUserDefaults.standardUserDefaults().boolForKey(Setting.ShowNSFW.rawValue), animated: false)
        
        cacheLabel.text = NSLocalizedString("filter_text_cache", comment: "")
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
    
}
