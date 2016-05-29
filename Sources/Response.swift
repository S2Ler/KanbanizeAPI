
import Foundation

public enum ClientError: ErrorType {
  case WrongResponseFormat
  case APIError(response: String)
  case JSONMallformed
  case NetworkError(NSError)
}

public protocol APIResult {
  init?(jsonObject: AnyObject)
}

internal struct DataParser {
  static func parse<T: APIResult>(data: NSData) throws -> T {
    let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
    
    if let result = T(jsonObject: jsonObject) {
      return result
    }
    else if let clientError = tryParseErrorJSON(jsonObject) {
      throw clientError
    }
    else {
      throw ClientError.WrongResponseFormat
    }
  }
  
  internal static func tryParseErrorJSON(jsonObject: AnyObject) -> ClientError? {
    guard let json = jsonObject as? Dictionary<String, AnyObject> else { return nil }
    
    print("Error: \(json)")
    
    guard let status = json["status"] as? Bool,
      let response = json["response"] as? String where status == false
      else { return nil }
    return ClientError.APIError(response: response)
  }

}

public enum Result<T, Error: ErrorType> {
  case Success(T)
  case Failure(Error)
  
  public init(value: T) {
    self = .Success(value)
  }
  
  public init(error: Error) {
    self = .Failure(error)
  }
}