
import Foundation

public enum ClientError: Error {
  case wrongResponseFormat
  case apiError(response: String)
  case jsonMallformed
  case networkError(Error)
}

public protocol APIResult {
  init?(jsonObject: AnyObject)
}

internal struct DataParser {
  static func parse<T: APIResult>(_ data: Data) throws -> T {
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
    
    if let result = T(jsonObject: jsonObject as AnyObject) {
      return result
    }
    else if let clientError = tryParseErrorJSON(jsonObject as AnyObject) {
      throw clientError
    }
    else {
      throw ClientError.wrongResponseFormat
    }
  }
  
  internal static func tryParseErrorJSON(_ jsonObject: AnyObject) -> ClientError? {
    guard let json = jsonObject as? Dictionary<String, AnyObject> else { return nil }
    
    print("Error: \(json)")
    
    guard let status = json["status"] as? Bool,
      let response = json["response"] as? String , status == false
      else { return nil }
    return ClientError.apiError(response: response)
  }

}

public enum Result<T, ErrorType: Error> {
  case success(T)
  case failure(ErrorType)
  
  public init(value: T) {
    self = .success(value)
  }
  
  public init(error: ErrorType) {
    self = .failure(error)
  }
}
