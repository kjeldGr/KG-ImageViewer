//
//  IntroViewController.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 28-09-15.
//  Copyright © 2015 KjeldGr. All rights reserved.
//

import UIKit
import RazzleDazzle
import DrawerController

class IntroViewController: AnimatedPagingScrollViewController {

    let pageControl = UIPageControl()
    let iPhoneImage = UIImageView(image: UIImage(named: "iPhoneIntro"))
    let searchLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        evo_drawerController?.centerHiddenInteractionMode = DrawerOpenCenterInteractionMode.None
        
        createIntroViews()
    }
    
    override func numberOfPages() -> Int {
        return 8
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(pageOffset))
        super.scrollViewDidScroll(scrollView)
        if pageOffset >= 3.0 && pageOffset < 4.0 {
            let stringLength = 8-Int(8.0*(4.0-pageOffset))
            searchLabel.text = "Airplane".substringToIndex(stringLength < 0 ? 0 : stringLength)
        }
    }
    
    func createIntroViews() {
        var alphaAnimation: AlphaAnimation!
        
        // Add Page control and Phone model
        
        pageControl.numberOfPages = numberOfPages()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.userInteractionEnabled = false
        contentView.addSubview(pageControl)
        if Helper.deviceType() == .iPhone6 || Helper.deviceType() == .iPhone6Plus {
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[self]-20-|", options: .AlignmentMask, metrics: nil, views: ["self": pageControl]))
        } else {
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[self]", options: .AlignmentMask, metrics: nil, views: ["self": pageControl]))
        }
        keepView(pageControl, onPages: [0,1,2,3,4,5,6])
        
        alphaAnimation = AlphaAnimation(view: pageControl)
        alphaAnimation.addKeyframe(6, value: 1)
        alphaAnimation.addKeyframe(6.01, value: 0)
        animator.addAnimation(alphaAnimation)
        
        var iPhoneOffset: CGFloat!
        switch Helper.deviceType() {
        case .iPhone5:
            iPhoneOffset = 20
        case .iPhone4:
            iPhoneOffset = -100
        default:
            iPhoneOffset = 100
        }
        contentView.addSubview(iPhoneImage)
        contentView.addConstraint(NSLayoutConstraint(item: iPhoneImage, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -iPhoneOffset))
        keepView(iPhoneImage, onPages: [0, 1, 2, 3, 4, 5, 6, 6.15])
        
        alphaAnimation = AlphaAnimation(view: iPhoneImage)
        alphaAnimation.addKeyframe(6, value: 1)
        alphaAnimation.addKeyframe(6.15, value: 1)
        alphaAnimation.addKeyframe(6.5, value: 0)
        animator.addAnimation(alphaAnimation)
        
        // First page
        
        var keepViewArray: [CGFloat]
        switch Helper.deviceType() {
        case .iPhone6:
            keepViewArray = [0, 0.15, 0.655, 2, 3]
        case .iPhone6Plus:
            keepViewArray = [0, 0.15, 0.686, 2, 3]
        default:
            keepViewArray = [0, 0.15, 0.592, 2, 3]
        }
        let homeScreen = screenshotForPages(keepViewArray, atTimes: [0, 0.15, 1, 2, 3], image: UIImage(named: "HomeIntro")!)
        
        alphaAnimation = AlphaAnimation(view: homeScreen)
        alphaAnimation.addKeyframe(1, value: 1)
        alphaAnimation.addKeyframe(2, value: 1)
        alphaAnimation.addKeyframe(3, value: 0)
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
        
        // Third page
        
        addLabelForPage(2, withText: NSLocalizedString("text_search_tap", comment: ""))
        
        // Fourth page
        
        addLabelForPage(3, withText: NSLocalizedString("text_search_term", comment: ""))
        
        let searchInactive = screenshotForPages([2, 3, 4], atTimes: [2, 3, 4], image: UIImage(named: "SearchDisabled")!)
        
        alphaAnimation = AlphaAnimation(view: searchInactive)
        alphaAnimation.addKeyframe(2, value: 0)
        alphaAnimation.addKeyframe(3, value: 1)
        alphaAnimation.addKeyframe(3.05, value: 0)
        animator.addAnimation(alphaAnimation)
        
        let searchActive = screenshotForPages([2, 3, 4, 5], atTimes: [2, 3, 4, 5], image: UIImage(named: "SearchEnabled")!)
        
        alphaAnimation = AlphaAnimation(view: searchActive)
        alphaAnimation.addKeyframe(3, value: 0)
        alphaAnimation.addKeyframe(3.01, value: 1)
        alphaAnimation.addKeyframe(4, value: 1)
        alphaAnimation.addKeyframe(5, value: 0)
        animator.addAnimation(alphaAnimation)
        
        // Fifth page
        
        addLabelForPage(4, withText: NSLocalizedString("text_search_go", comment: ""))
        
        let searchDone = screenshotForPages([4, 5, 6], atTimes: [4, 5, 6], image: UIImage(named: "SearchDone")!)
        
        alphaAnimation = AlphaAnimation(view: searchDone)
        alphaAnimation.addKeyframe(4, value: 0)
        alphaAnimation.addKeyframe(5, value: 1)
        alphaAnimation.addKeyframe(6, value: 0)
        animator.addAnimation(alphaAnimation)
        
        searchLabel.textColor = UIColor.blackColor()
        searchLabel.font = Helper.defaultFontWithType(.Regular, size: 7)
        contentView.addSubview(searchLabel)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[self(==110)]", options: .AlignmentMask, metrics: nil, views: ["self":searchLabel]))
        contentView.addConstraint(NSLayoutConstraint(item: searchLabel, attribute: .Top, relatedBy: .Equal, toItem: searchActive, attribute: .Top, multiplier: 1, constant: 55))
        keepView(searchLabel, onPages: [2.96, 3.96, 4.96, 5.96], atTimes: [3, 4, 5, 6])
        
        alphaAnimation = AlphaAnimation(view: searchLabel)
        alphaAnimation.addKeyframe(3, value: 0)
        alphaAnimation.addKeyframe(3.01, value: 1)
        alphaAnimation.addKeyframe(5, value: 1)
        alphaAnimation.addKeyframe(5.5, value: 0)
        animator.addAnimation(alphaAnimation)
        
        // Sixth page
        
        let detailScreen = screenshotForPages([4, 5, 6, 6.15], atTimes: [4, 5, 6, 6.15], image: UIImage(named: "DetailIntro")!)
        
        alphaAnimation = AlphaAnimation(view: detailScreen)
        alphaAnimation.addKeyframe(5, value: 0)
        alphaAnimation.addKeyframe(6, value: 1)
        alphaAnimation.addKeyframe(6.15, value: 1)
        alphaAnimation.addKeyframe(6.5, value: 0)
        animator.addAnimation(alphaAnimation)
        
        addLabelForPage(5, withText: NSLocalizedString("text_tap_detail", comment: ""))
        
        // Seventh page
        
        addLabelForPage(6, withText: NSLocalizedString("text_save", comment: ""))
        
        // Last page
        
        let appLabel = addLabelForPage(7, withText: NSLocalizedString("text_have_fun", comment: ""))
        appLabel.font = Helper.defaultFontWithType(.Regular, size: 26)
        
        let logoImage = UIImageView(image: UIImage(named: "Logo"))
        contentView.addSubview(logoImage)
        contentView.addConstraint(NSLayoutConstraint(item: logoImage, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        keepView(logoImage, onPages: [6.4, 7], atTimes: [6, 7])
        
        alphaAnimation = AlphaAnimation(view: logoImage)
        alphaAnimation.addKeyframe(6.6, value: 0)
        alphaAnimation.addKeyframe(7, value: 1)
        animator.addAnimation(alphaAnimation)
        
        let appTitleLabel = UILabel()
        appTitleLabel.text = "KG ImageViewer"
        appTitleLabel.textColor = UIColor.whiteColor()
        appTitleLabel.font = Helper.defaultFontWithType(.Semibold, size: 26)
        contentView.addSubview(appTitleLabel)
        contentView.addConstraint(NSLayoutConstraint(item: appTitleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: logoImage, attribute: .Top, multiplier: 1, constant: -15))
        keepView(appTitleLabel, onPages: [6.4, 7], atTimes: [6, 7])
        
        alphaAnimation = AlphaAnimation(view: appTitleLabel)
        alphaAnimation.addKeyframe(6.6, value: 0)
        alphaAnimation.addKeyframe(7, value: 1)
        animator.addAnimation(alphaAnimation)
        
        let startButton = UIButton()
        startButton.backgroundColor = UIColor.whiteColor()
        startButton.layer.cornerRadius = 4
        startButton.setTitle(NSLocalizedString("button_title_got_it", comment: ""), forState: .Normal)
        startButton.setTitleColor(Helper.mainColor, forState: .Normal)
        startButton.titleLabel?.font = Helper.defaultFontWithType(.Semibold, size: 18)
        startButton.addTarget(self, action: "startApp", forControlEvents: .TouchUpInside)
        contentView.addSubview(startButton)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[self(==buttonWidth)]", options: .AlignmentMask, metrics: ["buttonWidth": CGRectGetWidth(UIScreen.mainScreen().bounds)-40], views: ["self": startButton]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[self(==55)]-40-|", options: .AlignmentMask, metrics: nil, views: ["self": startButton]))
        keepView(startButton, onPages: [6.4, 7], atTimes: [6, 7])
        
        alphaAnimation = AlphaAnimation(view: startButton)
        alphaAnimation.addKeyframe(6.6, value: 0)
        alphaAnimation.addKeyframe(7, value: 1)
        animator.addAnimation(alphaAnimation)
        
        let againButton = UIButton()
        againButton.backgroundColor = UIColor.whiteColor()
        againButton.layer.cornerRadius = startButton.layer.cornerRadius
        againButton.setTitle(NSLocalizedString("button_title_again", comment: ""), forState: .Normal)
        againButton.setTitleColor(Helper.mainColor, forState: .Normal)
        againButton.titleLabel?.font = Helper.defaultFontWithType(.Semibold, size: 18)
        againButton.addTarget(self, action: "watchAgain", forControlEvents: .TouchUpInside)
        contentView.addSubview(againButton)
        contentView.addConstraint(NSLayoutConstraint(item: againButton, attribute: .Bottom, relatedBy: .Equal, toItem: startButton, attribute: .Top, multiplier: 1, constant: -15))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[self(==buttonWidth)]", options: .AlignmentMask, metrics: ["buttonWidth": CGRectGetWidth(UIScreen.mainScreen().bounds)-40], views: ["self": againButton]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[self(==55)]", options: .AlignmentMask, metrics: nil, views: ["self": againButton]))
        keepView(againButton, onPages: [6.4, 7], atTimes: [6, 7])
        
        alphaAnimation = AlphaAnimation(view: againButton)
        alphaAnimation.addKeyframe(6.6, value: 0)
        alphaAnimation.addKeyframe(7, value: 1)
        animator.addAnimation(alphaAnimation)
        
        contentView.bringSubviewToFront(iPhoneImage)
        
        // Add gestures
        
        let tapImage = UIImageView(image: UIImage(named: "Tap"))
        contentView.addSubview(tapImage)
        contentView.addConstraint(NSLayoutConstraint(item: tapImage, attribute: .Top, relatedBy: .Equal, toItem: homeScreen, attribute: .Top, multiplier: 1, constant: -13))
        switch Helper.deviceType() {
        case .iPhone6:
            keepViewArray = [0.199, 1.199, 2.153, 3.153, 6.199, 6.349]
        case .iPhone6Plus:
            keepViewArray = [0.176, 1.176, 2.139, 3.139, 6.176, 6.326]
        default:
            keepViewArray = [0.23, 1.23, 2.184, 3.184, 6.23, 6.38]
        }
        keepView(tapImage, onPages: keepViewArray, atTimes: [0, 1, 2, 3, 6, 6.15])
        
        alphaAnimation = AlphaAnimation(view: tapImage)
        alphaAnimation.addKeyframe(0, value: 0)
        alphaAnimation.addKeyframe(0.05, value: 1)
        alphaAnimation.addKeyframe(0.15, value: 1)
        alphaAnimation.addKeyframe(0.2, value: 0)
        alphaAnimation.addKeyframe(2, value: 0)
        alphaAnimation.addKeyframe(2.05, value: 1)
        alphaAnimation.addKeyframe(2.45, value: 1)
        alphaAnimation.addKeyframe(2.5, value: 0)
        alphaAnimation.addKeyframe(6, value: 0)
        alphaAnimation.addKeyframe(6.05, value: 1)
        alphaAnimation.addKeyframe(6.5, value: 0)
        animator.addAnimation(alphaAnimation)
        
        let fingerImage = UIImageView(image: UIImage(named: "Finger"))
        contentView.addSubview(fingerImage)
        let fingerConstraint = NSLayoutConstraint(item: fingerImage, attribute: .Top, relatedBy: .Equal, toItem: tapImage, attribute: .Top, multiplier: 1, constant: 22)
        contentView.addConstraint(fingerConstraint)
        switch Helper.deviceType() {
        case .iPhone6:
            keepViewArray = [0.22, 1.22, 2.176, 3.176, 6.22, 6.37]
        case .iPhone6Plus:
            keepViewArray = [0.197, 1.197, 2.153, 3.153, 6.197, 6.347]
        default:
            keepViewArray = [0.251, 1.251, 2.201, 3.201, 6.251, 6.401]
        }
        keepView(fingerImage, onPages: keepViewArray, atTimes: [0, 1, 2, 3, 6, 6.15])
        
        let constantAnimation = ConstraintConstantAnimation(superview: contentView, constraint: fingerConstraint)
        constantAnimation.addKeyframe(0, value: 32)
        constantAnimation.addKeyframe(0.05, value: 27)
        constantAnimation.addKeyframe(0.1, value: 32)
        constantAnimation.addKeyframe(2, value: 32)
        constantAnimation.addKeyframe(2.05, value: 27)
        constantAnimation.addKeyframe(2.1, value: 32)
        constantAnimation.addKeyframe(6, value: 32)
        constantAnimation.addKeyframe(6.05, value: 27)
        constantAnimation.addKeyframe(6.1, value: 32)
        animator.addAnimation(constantAnimation)
        
        alphaAnimation = AlphaAnimation(view: fingerImage)
        alphaAnimation.addKeyframe(0.0, value: 0)
        alphaAnimation.addKeyframe(0.05, value: 1)
        alphaAnimation.addKeyframe(0.15, value: 1)
        alphaAnimation.addKeyframe(0.25, value: 0)
        alphaAnimation.addKeyframe(2.0, value: 0)
        alphaAnimation.addKeyframe(2.05, value: 1)
        alphaAnimation.addKeyframe(2.45, value: 1)
        alphaAnimation.addKeyframe(2.55, value: 0)
        alphaAnimation.addKeyframe(6.0, value: 0)
        alphaAnimation.addKeyframe(6.05, value: 1)
        alphaAnimation.addKeyframe(6.5, value: 0)
        animator.addAnimation(alphaAnimation)

    }
    
    func screenshotForPages(pages: [CGFloat], atTimes: [CGFloat], image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        contentView.addSubview(imageView)
        keepView(imageView, onPages: pages, atTimes: atTimes)
        contentView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: iPhoneImage, attribute: .Top, multiplier: 1, constant: 49.5))
        return imageView
    }
    
    func addLabelForPage(page: CGFloat, withText text: String) -> UILabel {
        let label = UILabel()
        label.font = Helper.defaultFontWithType(.Regular, size: 17)
        label.textColor = UIColor.whiteColor()
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        contentView.addSubview(label)
        contentView.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 60))
        keepView(label, onPages: [page-0.6, page, page-0.4], atTimes: [page-1, page, page+1])
        
        let alphaAnimation = AlphaAnimation(view: label)
        alphaAnimation.addKeyframe(page-1, value: 0)
        alphaAnimation.addKeyframe(page, value: 1)
        alphaAnimation.addKeyframe(page+0.4, value: 0)
        animator.addAnimation(alphaAnimation)
        
        return label
    }
    
    func watchAgain() {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func startApp() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: Setting.ShowedIntro.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        evo_drawerController?.setCenterViewController(storyboard!.instantiateViewControllerWithIdentifier(View.PhotoGrid.rawValue), withCloseAnimation: false, completion: nil)
    }

}
