@testable import App
import Vapor
import FluentSQLite
import XCTest

final class UserTests: XCTestCase {
    let userMail = "jambon@yopmail.com"
    var app: Application!
    var conn: SQLiteConnection!
    
    override func setUp() {
        super.setUp()
        
        app = try! Application.testable()
        conn = try! app.newConnection(to: .sqlite).wait()
    }
    
    override func tearDown() {
        super.tearDown()
        conn.close()
    }
    
    func testRegister() throws {
        let user = User(email: userMail, password: "Qwerty1!")
        let createUserResponse = try app.sendRequest(to: "http://localhost:8080/register", method: .POST, body: user, isLoggedInRequest: false)
        let receivedUser = try createUserResponse.content.decode(User.UserPublic.self).wait()
        
        XCTAssertEqual(receivedUser.email, userMail)
        XCTAssertNotNil(receivedUser.id)
        
        let getUsersResponse = try app.sendRequest(to: "login", method: .POST, body: user)
        let receivedUsers = try getUsersResponse.content.decode(Token.self).wait()
        
        XCTAssertNotNil(receivedUsers.token)
    }
    
    
    static let allTests = [
        ("testRegister", testRegister)
    ]
 }
