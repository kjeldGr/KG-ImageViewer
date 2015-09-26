//
//  Loader.swift
//  Blendle Assignment
//
//  Created by Kjeld Groot on 26-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import Spring
import QuartzCore

class Loader: UIView {
    
    @IBOutlet weak var loaderImage: SpringImageView!
    private var animating = false
    
    init() {
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func doAnimation() {
        if animating == false {
            return
        }
        let duration: CGFloat = 1.0
        
        loaderImage.animation = Spring.AnimationPreset.Pop.rawValue
        loaderImage.duration = duration
        loaderImage.rotate = 4
//        loaderImage.delay = 0.2
        loaderImage.animate()
        
        loaderImage.animateNext { () -> () in
//            self.doAnimation()
            self.performSelector("doAnimation", withObject: nil, afterDelay: NSTimeInterval(0.2))
        }
        
    }
    
    func startAnimating() {
        animating = true
        doAnimation()
    }
    
    func stopAnimating() {
        animating = false
    }

}
