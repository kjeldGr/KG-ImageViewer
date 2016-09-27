//
//  KG_ImageViewerUITests.swift
//  KG ImageViewerUITests
//
//  Created by Kjeld Groot on 10-08-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import XCTest

enum ScrollDirection: Int {
    case left, right, up, down
}

extension XCUIElement {
    
    func isVisible(inSuperViewElement superElement: XCUIElement = XCUIApplication().windows.element(boundBy: 0)) -> Bool {
        guard exists && !frame.isEmpty else { return false }
        guard isHittable else { return false }
        return superElement.frame.contains(frame)
    }
    
    func scroll(toDirection scrollDirection: ScrollDirection) {
        switch scrollDirection {
        case .left:
            swipeRight()
        case .right:
            swipeLeft()
        case .up:
            swipeDown()
        case .down:
            swipeUp()
        }
    }
    
    func scroll(toView view: XCUIElement, scrollDirection: ScrollDirection = .right) -> XCUIElement {
        var tries = 0
        // Swipe left until button is visible
        while !view.isVisible(inSuperViewElement: self) {
            scroll(toDirection: scrollDirection)
            tries += 1
            XCTAssert(tries < 10, "View not found in scrollview")
        }
        return view
    }
    
}

class KG_ImageViewerUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnboarding() {
        // Set showed intro to false to make sure intro is showed
        launchApp(shouldShowIntro: true)
        
        let scrollView = XCUIApplication().scrollViews["IntroScrollView"]
        // Wait until the scrollview's layout is set
        waitUntilElementExists(scrollView, waitTime: 1)
        
        let watchAgainButton = XCUIApplication().buttons["IntroWatchAgainButton"]
        let startAppButton = XCUIApplication().buttons["IntroStartAppButton"]
        // Scroll to end and test watch again
        scrollView.scroll(toView: watchAgainButton).tap()
        
        // Start the app
        scrollView.scroll(toView: startAppButton).tap()
        
        // Check if the photo grid is shown
        let photoGridCollectionView = XCUIApplication().otherElements.collectionViews["PhotoGridCollectionView"]
        // First check if collection view exists
        XCTAssert(photoGridCollectionView.exists, "Photo Grid CollectionView doesn't exist")
        // When collectionview exists, check if it's visible
        let collectionViewIsVisible = photoGridCollectionView.isVisible()
        XCTAssert(collectionViewIsVisible, "Photo Grid CollectionView should be visible")
    }
    
    func testImagesScrolling() {
        launchApp()
        
        let photoGridCollectionView = XCUIApplication().otherElements.collectionViews["PhotoGridCollectionView"]
        
        // Wait until items are loaded
        let imageCell = photoGridCollectionView.cells.element(boundBy: 0)
        waitUntilElementExists(imageCell, waitTime: 5)
        
        // Check if loader becomes visible when scrolling
        photoGridCollectionView.swipeUp()
        let loader = XCUIApplication().otherElements["Loader"]
        XCTAssert(loader.exists, "Loader doesn't exist")
    }
    
    func testImageDetail() {
        launchApp()
        
        let photoGridCollectionView = XCUIApplication().otherElements.collectionViews["PhotoGridCollectionView"]
        
        // Wait until items are loaded
        let imageCell = photoGridCollectionView.cells.element(boundBy: 0)
        waitUntilElementExists(imageCell, waitTime: 5)
        let itemVisible = imageCell.isVisible()
        XCTAssert(itemVisible, "Cell should be visible")
        
        imageCell.tap()
        let detailImageView = XCUIApplication().images["DetailImageView"]
        waitUntilElementExists(detailImageView, waitTime: 3)
        detailImageView.swipeLeft()
        
    }
    
}

// Test helper functions
extension KG_ImageViewerUITests {
    
    func launchApp(shouldShowIntro showIntro: Bool = false) {
        let showedIntro = showIntro ? "NO" : "YES"
        let app = XCUIApplication()
        app.launchArguments += ["-ShowedIntro", showedIntro]
        app.launch()
    }
    
    func waitUntilElementExists(_ element: XCUIElement, waitTime: TimeInterval) {
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: waitTime, handler: nil)
    }
    
}
