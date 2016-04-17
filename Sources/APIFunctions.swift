
import Foundation

enum Function {
  case Login
  case LogTime
  
  var name: String {
    switch self {
    case .Login:
      return "login"
    case .LogTime:
      return "log_time"
    }
  }
}