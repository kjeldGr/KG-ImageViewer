//
//  KG_ImageViewerUITests.swift
//  KG ImageViewerUITests
//
//  Created by Kjeld Groot on 10-08-16.
//  Copyright © 2016 KjeldGr. All rights reserved.
//

import XCTest

enum ScrollDirection: Int {
    case Left, Right, Up, Down
}

extension XCUIElement {
    
    func scrollToDirection(scrollDirection: ScrollDirection) {
        switch scrollDirection {
        case .Left:
            swipeRight()
        case .Right:
            swipeLeft()
        case .Up:
            swipeDown()
        case .Down:
            swipeUp()
        }
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
        launchApp(true)
        
        let scrollView = XCUIApplication().scrollViews["IntroScrollView"]
        // Wait until the scrollview's layout is set
        waitUntilElementExists(scrollView, waitTime: 2)
        
        let watchAgainButton = XCUIApplication().buttons["IntroWatchAgainButton"]
        let startAppButton = XCUIApplication().buttons["IntroStartAppButton"]
        // Scroll to end and test watch again
        scrollToView(watchAgainButton, inScrollView: scrollView).tap()
        
        // Start the app
        scrollToView(startAppButton, inScrollView: scrollView).tap()
        
        // Check if the photo grid is shown
        let photoGridCollectionView = XCUIApplication().otherElements.collectionViews["PhotoGridCollectionView"]
        // First check if collection view exists
        waitUntilElementExists(photoGridCollectionView, waitTime: 3)
        // When collectionview exists, check if it's visible
        let collectionViewIsVisible = elementIsVisible(photoGridCollectionView)
        XCTAssert(collectionViewIsVisible, "CollectionView Should be visible")
    }
    
    func testImagesScrolling() {
        launchApp()
        
        let photoGridCollectionView = XCUIApplication().otherElements.collectionViews["PhotoGridCollectionView"]
        
        // Wait until items are loaded
        let imageCell = photoGridCollectionView.cells.elementBoundByIndex(0)
        waitUntilElementExists(imageCell, waitTime: 5)
        
        // Check if loader becomes visible when scrolling
        photoGridCollectionView.swipeUp()
        let loader = XCUIApplication().otherElements["Loader"]
        waitUntilElementExists(loader, waitTime: 3)
    }
    
    func testImageDetail() {
        launchApp()
        
        let photoGridCollectionView = XCUIApplication().otherElements.collectionViews["PhotoGridCollectionView"]
        
        // Wait until items are loaded
        let imageCell = photoGridCollectionView.cells.elementBoundByIndex(0)
        waitUntilElementExists(imageCell, waitTime: 5)
        let itemVisible = elementIsVisible(imageCell)
        XCTAssert(itemVisible, "Cell should be visible")
        
        imageCell.tap()
        let detailImageView = XCUIApplication().images["DetailImageView"]
        waitUntilElementExists(detailImageView, waitTime: 3)
        detailImageView.swipeLeft()
        
    }
    
}

// Test helper functions
extension KG_ImageViewerUITests {
    
    func launchApp(showIntro: Bool = false) {
        let shouldShowIntro = showIntro ? "YES" : "NO"
        let app = XCUIApplication()
        app.launchArguments += ["-ShouldShowIntro", shouldShowIntro]
        app.launch()
    }
    
    func scrollToView(viewElement: XCUIElement, inScrollView scrollView: XCUIElement, scrollDirection: ScrollDirection = .Right) -> XCUIElement {
        var tries = 0
        // Swipe left until button is visible
        while !elementIsVisible(viewElement, inSuperViewElement: scrollView) {
            scrollView.scrollToDirection(scrollDirection)
            tries += 1
            XCTAssert(tries < 10, "View not found in scrollview")
        }
        return viewElement
    }
    
    func elementIsVisible(element: XCUIElement, inSuperViewElement superElement: XCUIElement = XCUIApplication().windows.elementBoundByIndex(0)) -> Bool {
        guard element.exists && !CGRectIsEmpty(element.frame) else { return false }
        return CGRectContainsRect(superElement.frame, element.frame)
    }
    
    func waitUntilElementExists(element: XCUIElement, waitTime: NSTimeInterval) {
        let exists = NSPredicate(format: "exists == 1")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)
        waitForExpectationsWithTimeout(waitTime, handler: nil)
    }
    
}
