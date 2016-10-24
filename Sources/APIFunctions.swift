
import Foundation

enum Function {
  case login
  case logTime
  case addComment
  
  var name: String {
    switch self {
    case .login:
      return "login"
    case .logTime:
      return "log_time"
    case .addComment:
      return "add_comment"
    }
  }
}
