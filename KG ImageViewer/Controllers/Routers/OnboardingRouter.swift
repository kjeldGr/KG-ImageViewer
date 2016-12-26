//
//  OnboardingRouter.swift
//  KG ImageViewer
//
//  Created by Kjeld Groot on 26-12-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import DrawerController

final class OnboardingRouter: DrawerControllerDescendantRouter<IntroViewController> {
    
    override var storyboard: UIStoryboard {
        return UIStoryboard(name: "Onboarding", bundle: Bundle.main)
    }
    
    override func setupFirstViewController() -> IntroViewController {
        guard let onboardingViewController = storyboard.viewController(withViewType: .intro) as? IntroViewController else {
            assert(false, "The first UIViewController for OnboardingRouter should be of type \"\(IntroViewController.self)\"")
        }
        return onboardingViewController
    }
    
}
