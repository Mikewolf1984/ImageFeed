
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
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        sleep(5)
        loginTextField.tap()
        sleep(3)
        loginTextField.typeText("") //Личные данные!
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        passwordTextField.tap()
        sleep(3)
        passwordTextField.typeText("") //Личные данные!
        sleep(3)
        webView.buttons["Login"].tap()
        sleep(10)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        let likeButton = cellToLike.buttons["likeButton"]
        likeButton.tap()
        cellToLike.tap()
        sleep(5)
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["navSingleBackButton"]
        navBackButtonWhiteButton.tap()
    }
    func testProfile() throws {
        sleep(5)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(5)
        XCTAssertTrue(app.staticTexts[""].exists) //Личные данные!
        XCTAssertTrue(app.staticTexts[""].exists) //Личные данные!
        
        let navProfileExitButton = app.buttons["navProfileExitButton"]
        
        navProfileExitButton.tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
