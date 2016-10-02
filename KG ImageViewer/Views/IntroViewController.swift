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
    
    func addKeyFrames(_ keyFrames: [(time: CGFloat, value: T)]) {
        for keyFrame in keyFrames {
            addKeyframe(keyFrame.time, value: keyFrame.value)
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

        UIApplication.shared.statusBarStyle = .lightContent
        evo_drawerController?.centerHiddenInteractionMode = .none
        
        scrollView.accessibilityLabel = "IntroScrollView"
        
        createIntroViews()
    }
    
    override func numberOfPages() -> Int {
        return pages
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(pageOffset))
        super.scrollViewDidScroll(scrollView)
        if pageOffset >= 3.0 && pageOffset < 4.0 {
            var stringLength = 8-Int(8.0*(4.0-pageOffset))
            stringLength = stringLength < 0 ? 0 : stringLength
            let searchString = "Airplane"
            searchLabel.text = searchString.substring(to: searchString.index(searchString.startIndex, offsetBy: stringLength))
        }
    }
    
    func addAnimation(_ animation: Animatable, withKeyFrames keyFrames:[(time: CGFloat, value: CGFloat)]) {
        if let floatAnimation = animation as? Animation<CGFloat> {
            floatAnimation.addKeyFrames(keyFrames)
        }
        animator.addAnimation(animation)
    }
    
    func createIntroViews() {
        // Add Page control and Phone model
        pageControl.numberOfPages = numberOfPages()
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.isUserInteractionEnabled = false
        contentView.addSubview(pageControl)
        if Helper.deviceType() == .iPhone6 || Helper.deviceType() == .iPhone6Plus {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pageControl]-20-|", options: .alignmentMask, metrics: nil, views: ["pageControl": pageControl]))
        } else {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[pageControl]", options: .alignmentMask, metrics: nil, views: ["pageControl": pageControl]))
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
        iPhoneImage.snp.makeConstraints { (make) -> Void in
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
        let homeScreen = screenshot(forPages: keepViewArray, atTimes: [0, 0.15, 1, 2, 3], image: UIImage(named: "HomeIntro")!)
        addAnimation(AlphaAnimation(view: homeScreen), withKeyFrames: [(1, 1), (2, 1), (3, 0), (4, 0)])
        
        let blurView = UIImageView(image: UIImage.image(withColor: .white, size: CGSize(width: homeScreen.frame.width*0.7, height: homeScreen.frame.height)).applyBlurWithRadius(5, tintColor: Helper.mainColor.withAlphaComponent(0.5), saturationDeltaFactor: 1.8))
        homeScreen.addSubview(blurView)
        
        addAnimation(AlphaAnimation(view: blurView), withKeyFrames: [(0.4, 0), (1, 0.6), (1.3, 0)])
        
        addLabel(forPage: 0, withText: "text_home_screen".localize())
        
        // Second page
        let settingsScreen = screenshot(forPages: [0, 1, 2, 3], atTimes: [0, 1, 2, 3], image: UIImage(named: "SettingsIntro")!)
        contentView.bringSubview(toFront: homeScreen)
        
        addAnimation(AlphaAnimation(view: settingsScreen), withKeyFrames: [(0, 1), (1, 1), (2, 1), (2.01, 0)])
        
        addLabel(forPage: 1, withText: "text_filter_settings".localize())
        
        // Third page
        addLabel(forPage: 2, withText: "text_search_tap".localize())
        
        // Fourth page
        addLabel(forPage: 3, withText: "text_search_term".localize())
        
        let searchInactive = screenshot(forPages: [2, 3, 4], atTimes: [2, 3, 4], image: UIImage(named: "SearchDisabled")!)

        addAnimation(AlphaAnimation(view: searchInactive), withKeyFrames: [(2, 0), (3, 1), (3.05, 0)])
        
        let searchActive = screenshot(forPages: [2, 3, 4, 5], atTimes: [2, 3, 4, 5], image: UIImage(named: "SearchEnabled")!)
        
        addAnimation(AlphaAnimation(view: searchActive), withKeyFrames: [(3, 0), (3.01, 1), (4, 1), (5, 0)])
        
        // Fifth page
        addLabel(forPage: 4, withText: "text_search_go".localize())
        
        let searchDone = screenshot(forPages: [4, 5, 6], atTimes: [4, 5, 6], image: UIImage(named: "SearchDone")!)
        
        addAnimation(AlphaAnimation(view: searchDone), withKeyFrames: [(4, 0), (5, 1), (6, 0)])
        
        searchLabel.textColor = UIColor.black
        searchLabel.font = UIFont.font(withType: .Regular, size: .paragraph1)
        contentView.addSubview(searchLabel)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchLabel(==110)]", options: .alignmentMask, metrics: nil, views: ["searchLabel":searchLabel]))
        searchLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(searchActive).offset(55)
        }
        keepView(searchLabel, onPages: [2.96, 3.96, 4.96, 5.96], atTimes: [3, 4, 5, 6])
        addAnimation(AlphaAnimation(view: searchLabel), withKeyFrames: [(3, 0), (3.01, 1), (5, 1), (5.5, 0)])
        
        // Sixth page
        let detailScreen = screenshot(forPages: [4, 5, 6, 6.15], atTimes: [4, 5, 6, 6.15], image: UIImage(named: "DetailIntro")!)
        addAnimation(AlphaAnimation(view: detailScreen), withKeyFrames: [(5, 0), (6, 1), (6.15, 1), (6.5, 0)])
        
        addLabel(forPage: 5, withText: "text_tap_detail".localize())
        
        // Seventh page
        addLabel(forPage: 6, withText: "text_save".localize())
        
        // Last page
        let appLabel = addLabel(forPage: 7, withText: "text_have_fun".localize())
        appLabel.font = UIFont.font(withType: .Regular, size: .heading4)
        
        let logoImage = UIImageView(image: UIImage(named: "Logo"))
        contentView.addSubview(logoImage)
        logoImage.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(contentView)
        }
        keepView(logoImage, onPages: [6.4, 7], atTimes: [6, 7])
        addAnimation(AlphaAnimation(view: logoImage), withKeyFrames: [(6.6, 0), (7, 1)])
        
        let appTitleLabel = UILabel()
        appTitleLabel.text = "KG ImageViewer"
        appTitleLabel.textColor = UIColor.white
        appTitleLabel.font = UIFont.font(withType: .Semibold, size: .heading4)
        contentView.addSubview(appTitleLabel)
        appTitleLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(logoImage.snp.top).offset(-15)
        }
        keepView(appTitleLabel, onPages: [6.4, 7], atTimes: [6, 7])
        addAnimation(AlphaAnimation(view: appTitleLabel), withKeyFrames: [(6.6, 0), (7, 1)])
        
        let startButton = addButton(withTitle: "button_title_got_it".localize(), selector: #selector(IntroViewController.startApp), pageTimes: [(6.4, 6), (7, 7)])
        startButton.accessibilityLabel = "IntroStartAppButton"
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[startButton(==buttonWidth)]", options: .alignmentMask, metrics: ["buttonWidth": UIScreen.main.bounds.width-40], views: ["startButton": startButton]) + NSLayoutConstraint.constraints(withVisualFormat: "V:[startButton(==55)]-40-|", options: .alignmentMask, metrics: nil, views: ["startButton": startButton]))
        addAnimation(AlphaAnimation(view: startButton), withKeyFrames: [(6.6, 0), (7, 1)])
        
        let againButton = addButton(withTitle: "button_title_again".localize(), selector: #selector(IntroViewController.watchAgain), pageTimes: [(6.4, 6), (7, 7)])
        againButton.accessibilityLabel = "IntroWatchAgainButton"
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[againButton(==buttonWidth)]", options: .alignmentMask, metrics: ["buttonWidth": UIScreen.main.bounds.width-40], views: ["againButton": againButton]) + NSLayoutConstraint.constraints(withVisualFormat: "V:[againButton(==55)]", options: .alignmentMask, metrics: nil, views: ["againButton": againButton]))
        againButton.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(startButton.snp.top).offset(-15)
        }
        addAnimation(AlphaAnimation(view: againButton), withKeyFrames: [(6.6, 0), (7, 1)])
        
        contentView.bringSubview(toFront: iPhoneImage)
        
        // Add gestures
        let tapImage = UIImageView(image: UIImage(named: "Tap"))
        contentView.addSubview(tapImage)
        tapImage.snp.makeConstraints { (make) -> Void in
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
        
        let fingerConstraint = NSLayoutConstraint(item: fingerImage, attribute: .top, relatedBy: .equal, toItem: tapImage, attribute: .top, multiplier: 1, constant: 22)
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
    
    func addButton(withTitle title: String, selector: Selector, pageTimes: [(page: CGFloat, time: CGFloat)]) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 4
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(Helper.mainColor, for: UIControlState())
        button.titleLabel?.font = UIFont.font(withType: .Semibold, size: .paragraph6)
        button.addTarget(self, action: selector, for: .touchUpInside)
        contentView.addSubview(button)
        keepView(button, onPages: pageTimes.map({return $0.page}), atTimes: pageTimes.map({return $0.time}))
        return button
    }
    
    func screenshot(forPages pages: [CGFloat], atTimes times: [CGFloat], image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        contentView.addSubview(imageView)
        keepView(imageView, onPages: pages, atTimes: times)
        imageView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(iPhoneImage).offset(49.5)
        }
        return imageView
    }
    
    @discardableResult func addLabel(forPage page: CGFloat, withText text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.font(withType: .Regular, size: .paragraph5)
        label.textColor = UIColor.white
        label.text = text
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView).offset(60)
        }
        keepView(label, onPages: [page-0.6, page, page-0.4], atTimes: [page-1, page, page+1])
        addAnimation(AlphaAnimation(view: label), withKeyFrames: [(page-1, 0), (page, 1), (page+0.4, 0)])
        
        return label
    }
    
    func watchAgain() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func startApp() {
        Setting.ShowedIntro.setTrue()
        
        evo_drawerController?.setCenterViewController(storyboard!.viewController(withViewType: .photoGrid), withCloseAnimation: false, completion: nil)
    }

}
