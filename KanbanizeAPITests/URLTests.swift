
import XCTest
@testable import KanbanizeAPI

class URLTests: XCTestCase {
  func testURLCreation() {
    XCTAssertNotNil(NSURL(subdomain: subdomain, function: Function.LogTime))
  }
}
