//
//  Loader.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import Spring
import QuartzCore

class Loader: UIView {
    
    @IBOutlet weak var loaderImage: SpringImageView!
    var animating = false {
        didSet {
            if animating {
                doAnimation()
            }
        }
    }
    
    func doAnimation() {
        if !animating {
            return
        }
        let duration: CGFloat = 1.0
        
        loaderImage.animation = Spring.AnimationPreset.Pop.rawValue
        loaderImage.duration = duration
        loaderImage.rotate = 4
        loaderImage.animate()
        
        loaderImage.animateNext { [unowned self] () -> () in
            self.performSelector("doAnimation", withObject: nil, afterDelay: NSTimeInterval(0.2))
        }
        
    }

}
