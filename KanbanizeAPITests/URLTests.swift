
import XCTest
@testable import KanbanizeAPI

class URLTests: XCTestCase {
  func testURLCreation() {
    XCTAssertNotNil(URL(subdomain: subdomain, function: Function.logTime))
  }
}
