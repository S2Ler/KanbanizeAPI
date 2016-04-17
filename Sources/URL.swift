
import Foundation

extension NSURL {
  convenience init(subdomain: String, function: Function) {
    let urlString = "https://\(subdomain).kanbanize.com/index.php/api/kanbanize/\(function.name)/format/json"
    self.init(string: urlString)!
  }
}
