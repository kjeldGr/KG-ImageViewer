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
}

class FilterViewController: UIViewController {

    @IBOutlet weak var nsfwSwitch: UISwitch!
    @IBOutlet weak var nsfwLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nsfwLabel.text = NSLocalizedString("filter_text_nsfw", comment: "")
        
        nsfwSwitch.setOn(NSUserDefaults.standardUserDefaults().boolForKey(Setting.ShowNSFW.rawValue), animated: false)
    }

    @IBAction func toggleNsfwSwitch(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(nsfwSwitch.on, forKey: Setting.ShowNSFW.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Setting.ShowNSFW.rawValue, object: nil)
    }
    
}
