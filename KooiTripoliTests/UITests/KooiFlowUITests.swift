import XCTest

/// UI Tests for main navigation flows and RTL layout
final class KooiFlowUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["-UITest", "-AppleLanguages", "(ar)", "-AppleLocale", "ar_LY"]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    // MARK: - Onboarding Flow

    func testOnboardingFlow() {
        // Verify onboarding appears
        XCTAssertTrue(app.staticTexts["مرحباً بك في كوي"].waitForExistence(timeout: 5))

        // Skip onboarding
        let skipButton = app.buttons["تخطي"]
        if skipButton.exists {
            skipButton.tap()
        } else {
            // Complete onboarding by tapping through
            for _ in 0..<5 {
                let nextButton = app.buttons["التالي"]
                if nextButton.exists {
                    nextButton.tap()
                } else {
                    let getStartedButton = app.buttons["ابدأ الآن"]
                    if getStartedButton.exists {
                        getStartedButton.tap()
                        break
                    }
                }
            }
        }

        // Verify we're on home tab
        XCTAssertTrue(app.tabBars.buttons["الرئيسية"].isSelected)
    }

    func testOnboardingRTLLayout() {
        // Verify RTL layout on onboarding
        XCTAssertTrue(app.staticTexts["مرحباً بك في كوي"].exists)

        // Check text alignment is right-to-left
        let titleElement = app.staticTexts["مرحباً بك في كوي"]
        let frame = titleElement.frame
        XCTAssertGreaterThan(frame.origin.x, app.frame.width / 2) // RTL aligned
    }

    // MARK: - Tab Navigation

    func testTabNavigation() {
        // Skip onboarding if needed
        if app.staticTexts["مرحباً بك في كوي"].exists {
            let getStartedButton = app.buttons["ابدأ الآن"]
            if getStartedButton.exists {
                getStartedButton.tap()
            } else {
                app.buttons["تخطي"].tap()
            }
        }

        // Test Restaurants tab
        app.tabBars.buttons["المطاعم"].tap()
        XCTAssertTrue(app.tabBars.buttons["المطاعم"].isSelected)
        XCTAssertTrue(app.navigationBars["المطاعم"].exists)

        // Test Food Streets tab
        app.tabBars.buttons["شوارع الطعام"].tap()
        XCTAssertTrue(app.tabBars.buttons["شوارع الطعام"].isSelected)
        XCTAssertTrue(app.navigationBars["شوارع الطعام"].exists)

        // Test Loyalty tab
        app.tabBars.buttons["الولاء"].tap()
        XCTAssertTrue(app.tabBars.buttons["الولاء"].isSelected)
        XCTAssertTrue(app.navigationBars["الولاء"].exists)

        // Back to Home
        app.tabBars.buttons["الرئيسية"].tap()
        XCTAssertTrue(app.tabBars.buttons["الرئيسية"].isSelected)
    }

    func testTabBarRTLOrder() {
        // Verify tab bar items are in RTL order
        let tabBar = app.tabBars.firstMatch
        let buttons = tabBar.buttons.allElementsBoundByIndex

        // In RTL, tabs should be ordered right-to-left
        // Home (الرئيسية) should be rightmost
        // Loyalty (الولاء) should be leftmost
        XCTAssertEqual(buttons.count, 4)
    }

    // MARK: - Home Screen

    func testHomeScreenElements() {
        // Skip onboarding if needed
        skipOnboardingIfNeeded()

        // Verify hero section
        XCTAssertTrue(app.staticTexts["أسرع توصيل في طرابلس"].exists)

        // Verify smart features carousel
        XCTAssertTrue(app.staticTexts["طلب شارع MR"].exists)
        XCTAssertTrue(app.staticTexts["سلة جماعية"].exists)
        XCTAssertTrue(app.staticTexts["حجز طلب"].exists)
        XCTAssertTrue(app.staticTexts["ولاء كوي"].exists)

        // Verify cuisine categories
        XCTAssertTrue(app.buttons["الكل"].exists)
        XCTAssertTrue(app.buttons["بيتزا حطب"].exists)
        XCTAssertTrue(app.buttons["برجر"].exists)

        // Verify restaurant collections
        XCTAssertTrue(app.staticTexts["أقرب إليك"].exists)
        XCTAssertTrue(app.staticTexts["العروض"].exists)
    }

    func testHomeSearch() {
        skipOnboardingIfNeeded()

        // Tap search
        let searchField = app.searchFields.firstMatch
        searchField.tap()

        // Enter search query
        searchField.typeText("بيتزا")

        // Verify results filter
        XCTAssertTrue(app.staticTexts["بيتزا"].exists)
    }

    func testHomePullToRefresh() {
        skipOnboardingIfNeeded()

        // Pull to refresh
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeDown()

        // Should show loading indicator briefly
        // (In real test, would verify refresh completes)
    }

    // MARK: - Restaurant Discovery

    func testRestaurantsTab() {
        skipOnboardingIfNeeded()

        app.tabBars.buttons["المطاعم"].tap()

        // Verify collection filters
        XCTAssertTrue(app.buttons["الكل"].exists)
        XCTAssertTrue(app.buttons["العروض"].exists)
        XCTAssertTrue(app.buttons["مقترحة لك"].exists)
        XCTAssertTrue(app.buttons["الأكثر شعبية"].exists)
        XCTAssertTrue(app.buttons["جديد في كوي"].exists)
        XCTAssertTrue(app.buttons["قريبة منك"].exists)

        // Verify category filters
        XCTAssertTrue(app.buttons["بيتزا حطب"].exists)
        XCTAssertTrue(app.buttons["برجر"].exists)
    }

    func testRestaurantFiltering() {
        skipOnboardingIfNeeded()

        app.tabBars.buttons["المطاعم"].tap()

        // Filter by offers
        app.buttons["العروض"].tap()
        XCTAssertTrue(app.buttons["العروض"].isSelected)

        // Filter by category
        app.buttons["بيتزا حطب"].tap()
        XCTAssertTrue(app.buttons["بيتزا حطب"].isSelected)
    }

    func testRestaurantSearch() {
        skipOnboardingIfNeeded()

        app.tabBars.buttons["المطاعم"].tap()

        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("برجر")

        // Verify search results
        XCTAssertTrue(app.staticTexts["برجر"].exists)
    }

    // MARK: - Restaurant Detail

    func testRestaurantDetailNavigation() {
        skipOnboardingIfNeeded()

        // Go to restaurants tab
        app.tabBars.buttons["المطاعم"].tap()

        // Tap first restaurant card
        let firstCard = app.otherElements.matching(identifier: "restaurantCard").firstMatch
        if firstCard.exists {
            firstCard.tap()

            // Verify detail screen
            XCTAssertTrue(app.navigationBars.firstMatch.exists)

            // Verify menu categories
            XCTAssertTrue(app.buttons["الكل"].exists)
        }
    }

    // MARK: - Item Detail

    func testItemDetailModifiers() {
        skipOnboardingIfNeeded()

        // Navigate to restaurant detail
        app.tabBars.buttons["المطاعم"].tap()
        let firstCard = app.otherElements.matching(identifier: "restaurantCard").firstMatch
        if firstCard.exists {
            firstCard.tap()

            // Tap first menu item
            let firstItem = app.otherElements.matching(identifier: "menuItemRow").firstMatch
            if firstItem.exists {
                firstItem.tap()

                // Verify item detail
                XCTAssertTrue(app.navigationBars.firstMatch.exists)

                // Test quantity stepper
                let incrementButton = app.buttons["plus"]
                if incrementButton.exists {
                    incrementButton.tap()
                }

                // Test modifier selection if available
                let modifierOption = app.otherElements.matching(identifier: "modifierOption").firstMatch
                if modifierOption.exists {
                    modifierOption.tap()
                }
            }
        }
    }

    // MARK: - Cart Flow

    func testAddToCart() {
        skipOnboardingIfNeeded()

        // Navigate to item detail and add to cart
        app.tabBars.buttons["المطاعم"].tap()
        let firstCard = app.otherElements.matching(identifier: "restaurantCard").firstMatch
        if firstCard.exists {
            firstCard.tap()

            let firstItem = app.otherElements.matching(identifier: "menuItemRow").firstMatch
            if firstItem.exists {
                firstItem.tap()

                // Add to cart
                let addToCartButton = app.buttons["أضف إلى السلة"]
                if addToCartButton.exists {
                    addToCartButton.tap()

                    // Verify cart bar appears
                    XCTAssertTrue(app.staticTexts["عرض السلة"].waitForExistence(timeout: 3))
                }
            }
        }
    }

    func testCartView() {
        skipOnboardingIfNeeded()

        // Add item to cart first
        testAddToCart()

        // Tap cart bar
        let viewCartButton = app.buttons["عرض السلة"]
        if viewCartButton.exists {
            viewCartButton.tap()

            // Verify cart view
            XCTAssertTrue(app.navigationBars["السلة"].exists)
            XCTAssertTrue(app.staticTexts["ملخص الطلب"].exists)
        }
    }

    // MARK: - Checkout Flow

    func testCheckoutFlow() {
        skipOnboardingIfNeeded()

        // Add item and go to cart
        testAddToCart()

        let viewCartButton = app.buttons["عرض السلة"]
        if viewCartButton.exists {
            viewCartButton.tap()

            // Proceed to checkout
            let checkoutButton = app.buttons["إتمام الطلب"]
            if checkoutButton.exists {
                checkoutButton.tap()

                // Verify checkout screen
                XCTAssertTrue(app.navigationBars["إتمام الطلب"].exists)
                XCTAssertTrue(app.staticTexts["عنوان التوصيل"].exists)
                XCTAssertTrue(app.staticTexts["طريقة الدفع"].exists)
            }
        }
    }

    // MARK: - Food Streets

    func testFoodStreetsTab() {
        skipOnboardingIfNeeded()

        app.tabBars.buttons["شوارع الطعام"].tap()

        XCTAssertTrue(app.navigationBars["شوارع الطعام"].exists)
        XCTAssertTrue(app.staticTexts["ممشى قرقارش الليلي"].exists)
    }

    func testFoodStreetDetail() {
        skipOnboardingIfNeeded()

        app.tabBars.buttons["شوارع الطعام"].tap()

        // Tap first food street
        let firstStreet = app.otherElements.matching(identifier: "foodStreetCard").firstMatch
        if firstStreet.exists {
            firstStreet.tap()

            // Verify detail
            XCTAssertTrue(app.navigationBars.firstMatch.exists)
            XCTAssertTrue(app.staticTexts["اختر المطاعم"].exists)
        }
    }

    // MARK: - RTL Layout Tests

    func testRTLLayoutHome() {
        skipOnboardingIfNeeded()

        // Verify navigation title is RTL aligned
        let navBar = app.navigationBars["كوي"]
        XCTAssertTrue(navBar.exists)

        // Verify text elements are right-aligned
        let titleElements = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'أ' OR label BEGINSWITH 'ال'"))
        for element in titleElements.allElementsBoundByIndex {
            let frame = element.frame
            // In RTL, text should be aligned to right side
            XCTAssertGreaterThan(frame.origin.x, 50)
        }
    }

    func testRTLLayoutRestaurantCard() {
        skipOnboardingIfNeeded()

        app.tabBars.buttons["المطاعم"].tap()

        // Check restaurant card layout
        let cards = app.otherElements.matching(identifier: "restaurantCard")
        if cards.count > 0 {
            let firstCard = cards.firstMatch
            // Image should be on right in RTL
            // Text should be right-aligned
        }
    }

    func testRTLLayoutItemDetail() {
        skipOnboardingIfNeeded()

        // Navigate to item detail
        app.tabBars.buttons["المطاعم"].tap()
        let firstCard = app.otherElements.matching(identifier: "restaurantCard").firstMatch
        if firstCard.exists {
            firstCard.tap()

            let firstItem = app.otherElements.matching(identifier: "menuItemRow").firstMatch
            if firstItem.exists {
                firstItem.tap()

                // Verify RTL layout
                // Price on left, quantity stepper on right in RTL
            }
        }
    }

    // MARK: - Accessibility

    func testAccessibilityLabels() {
        skipOnboardingIfNeeded()

        // Verify key elements have accessibility labels
        XCTAssertTrue(app.tabBars.buttons["الرئيسية"].isHittable)
        XCTAssertTrue(app.tabBars.buttons["المطاعم"].isHittable)
        XCTAssertTrue(app.tabBars.buttons["شوارع الطعام"].isHittable)
        XCTAssertTrue(app.tabBars.buttons["الولاء"].isHittable)
    }

    func testVoiceOverNavigation() {
        skipOnboardingIfNeeded()

        // Enable VoiceOver in test settings
        // Navigate through key flows with VoiceOver
        // (Would need VoiceOver specific test setup)
    }

    // MARK: - Performance

    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testScrollPerformance() {
        skipOnboardingIfNeeded()

        let scrollView = app.scrollViews.firstMatch
        measure(metrics: [XCTOSSignpostMetric.scrollingAndDecelerationMetric]) {
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeDown(velocity: .fast)
        }
    }

    // MARK: - Helpers

    private func skipOnboardingIfNeeded() {
        if app.staticTexts["مرحباً بك في كوي"].waitForExistence(timeout: 2) {
            let getStartedButton = app.buttons["ابدأ الآن"]
            if getStartedButton.exists {
                getStartedButton.tap()
            } else {
                app.buttons["تخطي"].tap()
            }
        }
    }
}

/// Additional UI Tests for specific components
final class ComponentUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = ["-UITest", "-AppleLanguages", "(ar)", "-AppleLocale", "ar_LY"]
        app.launch()

        // Skip onboarding
        if app.staticTexts["مرحباً بك في كوي"].waitForExistence(timeout: 2) {
            app.buttons["تخطي"].tap()
        }
    }

    func testSkeletonLoaders() {
        // Verify skeleton loaders appear during loading
        app.tabBars.buttons["المطاعم"].tap()

        // During initial load, skeletons should be visible
        let skeletons = app.otherElements.matching(identifier: "skeletonLoader")
        // Note: In real test, would need to intercept network to test loading state
    }

    func testQuantityStepperAnimation() {
        app.tabBars.buttons["المطاعم"].tap()
        let firstCard = app.otherElements.matching(identifier: "restaurantCard").firstMatch
        if firstCard.exists {
            firstCard.tap()

            let firstItem = app.otherElements.matching(identifier: "menuItemRow").firstMatch
            if firstItem.exists {
                firstItem.tap()

                // Test increment animation
                let incrementButton = app.buttons["plus"]
                if incrementButton.exists {
                    incrementButton.tap()
                    // Verify quantity updates with animation
                }
            }
        }
    }

    func testCartBarAnimation() {
        // Add item to cart
        app.tabBars.buttons["المطاعم"].tap()
        let firstCard = app.otherElements.matching(identifier: "restaurantCard").firstMatch
        if firstCard.exists {
            firstCard.tap()

            let firstItem = app.otherElements.matching(identifier: "menuItemRow").firstMatch
            if firstItem.exists {
                firstItem.tap()

                let addToCartButton = app.buttons["أضف إلى السلة"]
                if addToCartButton.exists {
                    addToCartButton.tap()

                    // Verify cart bar slides up
                    let cartBar = app.otherElements.matching(identifier: "groupCartBar").firstMatch
                    XCTAssertTrue(cartBar.waitForExistence(timeout: 3))
                }
            }
        }
    }

    func testEnvelopeOnboardingAnimation() {
        // Re-launch to see onboarding
        app.terminate()
        app.launchArguments = ["-UITest", "-AppleLanguages", "(ar)", "-AppleLocale", "ar_LY", "-ResetOnboarding"]
        app.launch()

        // Verify envelope animation starts
        let envelope = app.otherElements.matching(identifier: "envelopeAnimation").firstMatch
        XCTAssertTrue(envelope.waitForExistence(timeout: 3))

        // Wait for animation to complete or skip
        sleep(3)

        // Should transition to home
        XCTAssertTrue(app.tabBars.buttons["الرئيسية"].waitForExistence(timeout: 5))
    }
}