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
import SnapKit

extension Animation {
    
    func addKeyFrames(keyFrames: [(time: CGFloat, value: T)]) {
        for keyFrame in keyFrames {
            self.addKeyframe(keyFrame.time, value: keyFrame.value)
        }
    }
    
}

class IntroViewController: AnimatedPagingScrollViewController {

    let pageControl = UIPageControl()
    let iPhoneImage = UIImageView(image: UIImage(named: "iPhoneIntro"))
    let searchLabel = UILabel()
    let pages = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        evo_drawerController?.centerHiddenInteractionMode = DrawerOpenCenterInteractionMode.None
        
        createIntroViews()
    }
    
    override func numberOfPages() -> Int {
        return pages
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(pageOffset))
        super.scrollViewDidScroll(scrollView)
        if pageOffset >= 3.0 && pageOffset < 4.0 {
            let stringLength = 8-Int(8.0*(4.0-pageOffset))
            searchLabel.text = "Airplane".substringToIndex(stringLength < 0 ? 0 : stringLength)
        }
    }
    
    func addAnimation(animation: Animatable, withKeyFrames keyFrames:[(time: CGFloat, value: CGFloat)]) {
        if let floatAnimation = animation as? Animation<CGFloat> {
            floatAnimation.addKeyFrames(keyFrames)
        }
        animator.addAnimation(animation)
    }
    
    func createIntroViews() {
        // Add Page control and Phone model
        pageControl.numberOfPages = numberOfPages()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.userInteractionEnabled = false
        contentView.addSubview(pageControl)
        if Helper.deviceType() == .iPhone6 || Helper.deviceType() == .iPhone6Plus {
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pageControl]-20-|", options: .AlignmentMask, metrics: nil, views: ["pageControl": pageControl]))
        } else {
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[pageControl]", options: .AlignmentMask, metrics: nil, views: ["pageControl": pageControl]))
        }
        keepView(pageControl, onPages: [0,1,2,3,4,5,6])
        addAnimation(AlphaAnimation(view: pageControl), withKeyFrames: [(6, 1), (6.01, 0)])
        
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
        iPhoneImage.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(contentView).inset(iPhoneOffset)
        }
        keepView(iPhoneImage, onPages: [0, 1, 2, 3, 4, 5, 6, 6.15])
        addAnimation(AlphaAnimation(view: iPhoneImage), withKeyFrames: [(6, 1), (6.15, 1), (6.5, 0)])
        
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
        addAnimation(AlphaAnimation(view: homeScreen), withKeyFrames: [(1, 1), (2, 1), (3, 0), (4, 0)])
        
        let blurView = UIImageView(image: UIImage.imageWithColor(UIColor.whiteColor(), size: CGSizeMake(CGRectGetWidth(homeScreen.frame)*0.7, CGRectGetHeight(homeScreen.frame))).applyBlurWithRadius(5, tintColor: Helper.mainColor.colorWithAlphaComponent(0.5), saturationDeltaFactor: 1.8))
        homeScreen.addSubview(blurView)
        
        addAnimation(AlphaAnimation(view: blurView), withKeyFrames: [(0.4, 0), (1, 0.6), (1.3, 0)])
        
        addLabelForPage(0, withText: NSLocalizedString("text_home_screen", comment: ""))
        
        // Second page
        let settingsScreen = screenshotForPages([0, 1, 2, 3], atTimes: [0, 1, 2, 3], image: UIImage(named: "SettingsIntro")!)
        contentView.bringSubviewToFront(homeScreen)
        
        addAnimation(AlphaAnimation(view: settingsScreen), withKeyFrames: [(0, 1), (1, 1), (2, 1), (2.01, 0)])
        
        addLabelForPage(1, withText: NSLocalizedString("text_filter_settings", comment: ""))
        
        // Third page
        addLabelForPage(2, withText: NSLocalizedString("text_search_tap", comment: ""))
        
        // Fourth page
        addLabelForPage(3, withText: NSLocalizedString("text_search_term", comment: ""))
        
        let searchInactive = screenshotForPages([2, 3, 4], atTimes: [2, 3, 4], image: UIImage(named: "SearchDisabled")!)

        addAnimation(AlphaAnimation(view: searchInactive), withKeyFrames: [(2, 0), (3, 1), (3.05, 0)])
        
        let searchActive = screenshotForPages([2, 3, 4, 5], atTimes: [2, 3, 4, 5], image: UIImage(named: "SearchEnabled")!)
        
        addAnimation(AlphaAnimation(view: searchActive), withKeyFrames: [(3, 0), (3.01, 1), (4, 1), (5, 0)])
        
        // Fifth page
        addLabelForPage(4, withText: NSLocalizedString("text_search_go", comment: ""))
        
        let searchDone = screenshotForPages([4, 5, 6], atTimes: [4, 5, 6], image: UIImage(named: "SearchDone")!)
        
        addAnimation(AlphaAnimation(view: searchDone), withKeyFrames: [(4, 0), (5, 1), (6, 0)])
        
        searchLabel.textColor = UIColor.blackColor()
        searchLabel.font = UIFont(familyName: .ProximaNova, fontType: .Regular, size: 7)
        contentView.addSubview(searchLabel)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[searchLabel(==110)]", options: .AlignmentMask, metrics: nil, views: ["searchLabel":searchLabel]))
        searchLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(searchActive).offset(55)
        }
        keepView(searchLabel, onPages: [2.96, 3.96, 4.96, 5.96], atTimes: [3, 4, 5, 6])
        addAnimation(AlphaAnimation(view: searchLabel), withKeyFrames: [(3, 0), (3.01, 1), (5, 1), (5.5, 0)])
        
        // Sixth page
        let detailScreen = screenshotForPages([4, 5, 6, 6.15], atTimes: [4, 5, 6, 6.15], image: UIImage(named: "DetailIntro")!)
        addAnimation(AlphaAnimation(view: detailScreen), withKeyFrames: [(5, 0), (6, 1), (6.15, 1), (6.5, 0)])
        
        addLabelForPage(5, withText: NSLocalizedString("text_tap_detail", comment: ""))
        
        // Seventh page
        addLabelForPage(6, withText: NSLocalizedString("text_save", comment: ""))
        
        // Last page
        let appLabel = addLabelForPage(7, withText: NSLocalizedString("text_have_fun", comment: ""))
        appLabel.font = UIFont(familyName: .ProximaNova, fontType: .Regular, size: 26)
        
        let logoImage = UIImageView(image: UIImage(named: "Logo"))
        contentView.addSubview(logoImage)
        logoImage.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
        }
        keepView(logoImage, onPages: [6.4, 7], atTimes: [6, 7])
        addAnimation(AlphaAnimation(view: logoImage), withKeyFrames: [(6.6, 0), (7, 1)])
        
        let appTitleLabel = UILabel()
        appTitleLabel.text = "KG ImageViewer"
        appTitleLabel.textColor = UIColor.whiteColor()
        appTitleLabel.font = UIFont(familyName: .ProximaNova, fontType: .Semibold, size: 26)
        contentView.addSubview(appTitleLabel)
        appTitleLabel.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(logoImage.snp_top).offset(-15)
        }
        keepView(appTitleLabel, onPages: [6.4, 7], atTimes: [6, 7])
        addAnimation(AlphaAnimation(view: appTitleLabel), withKeyFrames: [(6.6, 0), (7, 1)])
        
        let startButton = addButtonWithTitle(NSLocalizedString("button_title_got_it", comment: ""), selector: "startApp", pageTimes: [(6.4, 6), (7, 7)])
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[startButton(==buttonWidth)]", options: .AlignmentMask, metrics: ["buttonWidth": CGRectGetWidth(UIScreen.mainScreen().bounds)-40], views: ["startButton": startButton]) + NSLayoutConstraint.constraintsWithVisualFormat("V:[startButton(==55)]-40-|", options: .AlignmentMask, metrics: nil, views: ["startButton": startButton]))
        addAnimation(AlphaAnimation(view: startButton), withKeyFrames: [(6.6, 0), (7, 1)])
        
        let againButton = addButtonWithTitle(NSLocalizedString("button_title_again", comment: ""), selector: "watchAgain", pageTimes: [(6.4, 6), (7, 7)])
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[againButton(==buttonWidth)]", options: .AlignmentMask, metrics: ["buttonWidth": CGRectGetWidth(UIScreen.mainScreen().bounds)-40], views: ["againButton": againButton]) + NSLayoutConstraint.constraintsWithVisualFormat("V:[againButton(==55)]", options: .AlignmentMask, metrics: nil, views: ["againButton": againButton]))
        againButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(startButton.snp_top).offset(-15)
        }
        addAnimation(AlphaAnimation(view: againButton), withKeyFrames: [(6.6, 0), (7, 1)])
        
        contentView.bringSubviewToFront(iPhoneImage)
        
        // Add gestures
        let tapImage = UIImageView(image: UIImage(named: "Tap"))
        contentView.addSubview(tapImage)
        tapImage.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(homeScreen).offset(-13)
        }
        switch Helper.deviceType() {
        case .iPhone6:
            keepViewArray = [0.199, 1.199, 2.153, 3.153, 6.199, 6.349]
        case .iPhone6Plus:
            keepViewArray = [0.176, 1.176, 2.139, 3.139, 6.176, 6.326]
        default:
            keepViewArray = [0.23, 1.23, 2.184, 3.184, 6.23, 6.38]
        }
        keepView(tapImage, onPages: keepViewArray, atTimes: [0, 1, 2, 3, 6, 6.15])
        addAnimation(AlphaAnimation(view: tapImage), withKeyFrames: [(0, 0), (0.05, 1), (0.15, 1), (0.2, 0), (2, 0), (2.05, 1), (2.45, 1), (2.5, 0), (6, 0), (6.05, 1), (6.5, 0)])
        
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
        
        addAnimation(ConstraintConstantAnimation(superview: contentView, constraint: fingerConstraint), withKeyFrames: [(0, 32), (0.05, 27), (0.1, 32), (2, 32), (2.05, 27), (2.1, 32), (6, 32), (6.05, 27), (6.1, 32)])
        
        addAnimation(AlphaAnimation(view: fingerImage), withKeyFrames: [(0, 0), (0.05, 1), (0.15, 1), (0.2, 0), (2, 0), (2.05, 1), (2.45, 1), (2.5, 0), (6, 0), (6.05, 1), (6.5, 0)])

    }
    
    func addButtonWithTitle(title: String, selector: Selector, pageTimes: [(page: CGFloat, time: CGFloat)]) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 4
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(Helper.mainColor, forState: .Normal)
        button.titleLabel?.font = UIFont(familyName: .ProximaNova, fontType: .Semibold, size: 18)
        button.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
        contentView.addSubview(button)
        keepView(button, onPages: pageTimes.map({return $0.page}), atTimes: pageTimes.map({return $0.time}))
        return button
    }
    
    func screenshotForPages(pages: [CGFloat], atTimes: [CGFloat], image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        contentView.addSubview(imageView)
        keepView(imageView, onPages: pages, atTimes: atTimes)
        imageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(iPhoneImage).offset(49.5)
        }
        return imageView
    }
    
    func addLabelForPage(page: CGFloat, withText text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont(familyName: .ProximaNova, fontType: .Regular, size: 17)
        label.textColor = UIColor.whiteColor()
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        contentView.addSubview(label)
        label.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView).offset(60)
        }
        keepView(label, onPages: [page-0.6, page, page-0.4], atTimes: [page-1, page, page+1])
        addAnimation(AlphaAnimation(view: label), withKeyFrames: [(page-1, 0), (page, 1), (page+0.4, 0)])
        
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
