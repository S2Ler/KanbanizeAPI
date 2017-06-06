
import Foundation

//MARK: TaskID
public struct TaskID {
  public let value: String
  public init(_ taskID: String) {
    self.value = taskID
  }
  
  public init<T: FixedWidthInteger>(_ taskID: T) {
    self.value = String(describing: taskID)
  }
}

extension TaskID: RequestParam {
  var key: String {
    return "taskid"
  }
}

//MARK: Time
public struct LoggedTime {
  public let hours: Double
  
  public init(hours: Double) {
    self.hours = hours
  }
}

extension LoggedTime: RequestParam {
  var key: String {
    return "loggedtime"
  }
  
  var value: String {
    return String(hours)
  }
}

//MARK: Description
public struct Description {
  public let value: String
  
  public init(_ value: String) {
    self.value = value
  }
}

extension Description: RequestParam {
  var key: String {
    return "description"
  }
}

//MARK: Any Request Param
public protocol RequestParamValueConvertible {
  func convertToRequestParamValue() -> String
}

extension CustomStringConvertible {
  public func convertToRequestParamValue() -> String {
    return String(describing: self)
  }
}

extension Int: RequestParamValueConvertible {
  public func convertToRequestParamValue() -> String {
    return String(self)
  }
}

public struct AnyRequestParam {
  
  public let key: String
  public let value: String
  init(key: String, value: String) {
    self.key = key
    self.value = value
  }
  
  init<T: RequestParamValueConvertible>(key: String, value: T) {
    self.key = key
    self.value = value.convertToRequestParamValue()
  }
}

extension AnyRequestParam: RequestParam {
  
}


