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
        if !animating || loaderImage.isAnimating {
            return
        }
        let duration: CGFloat = 1.0
        
        loaderImage.animation = Spring.AnimationPreset.Pop.rawValue
        loaderImage.duration = duration
        loaderImage.rotate = 4
        loaderImage.animate()
        
        loaderImage.animateNext { [weak self] () -> () in
            guard let strongSelf = self else { return }
            strongSelf.perform(#selector(Loader.doAnimation), with: nil, afterDelay: TimeInterval(0.2))
        }
        
    }

}
