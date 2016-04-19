
import Foundation

enum Function {
  case Login
  case LogTime
  case AddComment
  
  var name: String {
    switch self {
    case .Login:
      return "login"
    case .LogTime:
      return "log_time"
    case .AddComment:
      return "add_comment"
    }
  }
}