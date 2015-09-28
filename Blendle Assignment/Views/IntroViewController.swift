//
//  IntroViewController.swift
//  Blendle Assignment
//
//  Created by Kjeld Groot on 28-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import RazzleDazzle

class IntroViewController: AnimatedPagingScrollViewController {

    let iPhoneImage = UIImageView(image: UIImage(named: "iPhoneIntro"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createIntroViews()
    }
    
    override func numberOfPages() -> Int {
        return 5
    }
    
    func createIntroViews() {
        contentView.addSubview(iPhoneImage)
        contentView.addConstraint(NSLayoutConstraint(item: iPhoneImage, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -100))
        keepView(iPhoneImage, onPages: [0, 1, 2, 3, 2.6])
        
        // First page
        let homeScreen = screenshotForPages([0, 0.655, 2, 3], atTimes: [0, 1, 2, 3], image: UIImage(named: "HomeIntro")!)
        var alphaAnimation = AlphaAnimation(view: homeScreen)
        alphaAnimation.addKeyframe(1, value: 1)
        alphaAnimation.addKeyframe(2, value: 1)
        alphaAnimation.addKeyframe(3, value: 1)
        alphaAnimation.addKeyframe(4, value: 0)
        animator.addAnimation(alphaAnimation)
        
        let blurView = UIImageView(image: UIColor.whiteColor().imageWithSize(CGSizeMake(CGRectGetWidth(homeScreen.frame)*0.7, CGRectGetHeight(homeScreen.frame))).applyBlurWithRadius(5, tintColor: Helper.mainColor.colorWithAlphaComponent(0.5), saturationDeltaFactor: 1.8))
        homeScreen.addSubview(blurView)
        alphaAnimation = AlphaAnimation(view: blurView)
        alphaAnimation.addKeyframe(0.4, value: 0)
        alphaAnimation.addKeyframe(1, value: 0.6)
        alphaAnimation.addKeyframe(1, value: 0.6)
        alphaAnimation.addKeyframe(1.3, value: 0)
        animator.addAnimation(alphaAnimation)
        
        addLabelForPage(0, withText: NSLocalizedString("text_home_screen", comment: ""))
        
        // Second page
        let settingsScreen = screenshotForPages([0, 1, 2, 3], atTimes: [0, 1, 2, 3], image: UIImage(named: "SettingsIntro")!)
        contentView.bringSubviewToFront(homeScreen)
        alphaAnimation = AlphaAnimation(view: settingsScreen)
        alphaAnimation.addKeyframe(0, value: 1)
        alphaAnimation.addKeyframe(1, value: 1)
        alphaAnimation.addKeyframe(2, value: 1)
        alphaAnimation.addKeyframe(2.01, value: 0)
        animator.addAnimation(alphaAnimation)
        
        addLabelForPage(1, withText: NSLocalizedString("text_filter_settings", comment: ""))
        
        // Fourth
        let detailScreen = screenshotForPages([2, 3, 4], atTimes: [2, 3, 4], image: UIImage(named: "DetailIntro")!)
        alphaAnimation = AlphaAnimation(view: detailScreen)
        alphaAnimation.addKeyframe(2, value: 0)
        alphaAnimation.addKeyframe(3, value: 1)
        alphaAnimation.addKeyframe(4, value: 0)
        animator.addAnimation(alphaAnimation)
        
        addLabelForPage(2, withText: NSLocalizedString("text_tap_detail", comment: ""))
        
        // Last page
        let startButton = UIButton()
        startButton.backgroundColor = UIColor.whiteColor()
        startButton.layer.cornerRadius = 32
        startButton.setTitle(NSLocalizedString("button_title_got_it", comment: ""), forState: .Normal)
        startButton.setTitleColor(Helper.mainColor, forState: .Normal)
        startButton.titleLabel?.font = Helper.defaultFontWith(.Semibold, size: 18)
        contentView.addSubview(startButton)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[self(==buttonWidth)]", options: .AlignmentMask, metrics: ["buttonWidth": CGRectGetWidth(UIScreen.mainScreen().bounds)-40], views: ["self": startButton]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[self(==64)]-40-|", options: .AlignmentMask, metrics: nil, views: ["self": startButton]))
        keepView(startButton, onPages: [3,4])
        
        alphaAnimation = AlphaAnimation(view: startButton)
        alphaAnimation.addKeyframe(3, value: 0)
        alphaAnimation.addKeyframe(4, value: 1)
        animator.addAnimation(alphaAnimation)
        
        contentView.bringSubviewToFront(iPhoneImage)
    }
    
    func screenshotForPages(pages: [CGFloat], atTimes: [CGFloat], image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        contentView.addSubview(imageView)
        keepView(imageView, onPages: pages, atTimes: atTimes)
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: iPhoneImage, attribute: .Top, multiplier: 1, constant: 49.5))
        return imageView
    }
    
    func addLabelForPage(page: CGFloat, withText text: String) {
        let label = UILabel()
        label.font = Helper.defaultFontWith(.Regular, size: 17)
        label.textColor = UIColor.whiteColor()
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        contentView.addSubview(label)
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 40))
        keepView(label, onPages: [page-0.6, page, page-0.4], atTimes: [page-1, page, page+1])
        
        let alphaAnimation = AlphaAnimation(view: label)
        alphaAnimation.addKeyframe(page-1, value: 0)
        alphaAnimation.addKeyframe(page, value: 1)
        alphaAnimation.addKeyframe(page+0.4, value: 0)
        animator.addAnimation(alphaAnimation)
    }

}
