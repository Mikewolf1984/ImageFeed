
import XCTest
final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["TestMode"]
        app.launch()
    }
    
    func testAuth() throws {
        
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        
        print(app.webViews.description)
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText("mike.volkov@icloud.com")
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        passwordTextField.tap()
        passwordTextField.typeText("MikeWolf1984")
        webView.buttons["Login"].tap()
        sleep(10)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        print(app.debugDescription)
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["likeButton"].tap()
        sleep(2)
        cellToLike.buttons["likeButton"].tap()
        sleep(2)
        
        cellToLike.tap()
        sleep(2)
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["navSingleBackButton"]
        navBackButtonWhiteButton.tap()
    }
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)
        XCTAssertTrue(app.staticTexts["Mike Volkov"].exists)
        XCTAssertTrue(app.staticTexts["@mikewolf1984"].exists)
        let exitButton = app.buttons["profileExitButton"]
        exitButton.tap()
        
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
