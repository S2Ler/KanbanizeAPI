
import XCTest
@testable import KanbanizeAPI

class ClientTests: XCTestCase {
  func testAPIKeyLogin() {
    XCTAssertTrue(client().isLoggedIn)
  }
  
  func testEmailPasswordLogin() {
    let loggedIn = expectation(description: "Logged In")
    client((email: validEmail, password: validPassword)).login {
      if case .success = $0 {
        loggedIn.fulfill()
      }
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testInvalidEmailLogin() {
    let apiError = expectation(description: "API Error")
    client((email: "", password: "")).login {
      if case .failure(ClientError.apiError) = $0 {
        apiError.fulfill()
      }
    }
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testLogTime() {
    let c = client()
    let timeLogged = expectation(description: "Time Logged")
    try! c.logTime(LoggedTime(hours: 1),
                   taskID: TaskID(testTaskID), completion: { result in
                    switch result {
                    case .success(let logTimeInfo):
                      print(logTimeInfo)
                      timeLogged.fulfill()
                    case .failure(let error):
                      print(error)
                    }
    })
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testAddComment() {
    let c = client()
    let commentAdded = expectation(description: "Comment Added")
    try! c.addComment("A Comment",
                      taskID: TaskID(testTaskID), completion: { result in
                        switch result {
                        case .success(let logTimeInfo):
                          print(logTimeInfo)
                          commentAdded.fulfill()
                        case .failure(let error):
                          print(error)
                        }
    })
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func client(_ passwordLogin: (email: String, password: String)? = nil) -> KanbanizeAPI.Client {
    if let login = passwordLogin {
      return Client(subdomain: subdomain,
                    loginInfo: .password(email: login.email, password: login.password))
    }
    return Client(subdomain: subdomain, loginInfo: .apiKey(apiKey))
  }
  
}
