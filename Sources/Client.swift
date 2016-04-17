
import Foundation

public final class Client {
  internal let subdomain: String
  internal let loginInfo: LoginInfo
  private(set) internal var credentials: Credentials?
  internal let executor: Executor
  
  public init(subdomain: String, loginInfo: LoginInfo, executor: Executor = SimpleExecutor()) {
    self.subdomain = subdomain
    self.loginInfo = loginInfo
    self.executor = executor
  }
  
  public enum LoginInfo {
    case APIKey(String)
    case Password(email: String, password: String)
    //    case TwoFactorAuthentication(email, String, password: String, oneTimePassword: String)
  }
  
  internal struct Credentials {
    let apiKey: String
    let oneTimePassword: String?
    
    init(apiKey: String, oneTimePassword: String? = nil) {
      self.apiKey = apiKey
      self.oneTimePassword = oneTimePassword
    }
  }
  
  public enum Error: ErrorType {
    case NotLoggedIn
  }
}

public extension Client {
  public struct RequestBuilder {
    private let client: Client
    private init(client: Client) {
      self.client = client
    }
    
    internal var subdomain: String {
      return client.subdomain
    }
    
    internal var loginInfo: LoginInfo {
      return client.loginInfo
    }
    
    internal var credentials: Credentials? {
      return client.credentials
    }
  }
  
  public func requestBuilder() throws -> RequestBuilder {
    return RequestBuilder(client: self)
  }
}

public protocol Executor {
  func execute(request: NSURLRequest, completion: (NSData?, NSURLResponse?, NSError?) -> Void)
}

internal extension Client {
  func execute<ResultType: APIResult>(request: NSURLRequest, completion: (Result<ResultType, ClientError>) -> Void) {
    executor.execute(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
      if let data = data {
        do {
          let parsedResult: ResultType = try DataParser.parse(data)
          completion(.Success(parsedResult))
        }
        catch let clientError as ClientError {
          completion(.Failure(clientError))
        }
        catch {
          completion(.Failure(.JSONMallformed))
        }
      }
      else {
        completion(.Failure(.NetworkError(error!)))
      }
    }
  }
}

public extension Client {
  public var isLoggedIn: Bool {
    return credentials != nil
  }
  /**
   Login client to Kanbanize API. Required before any other API calls.
   
   - parameter completion: May return nil `LoginResult` if `LoginInfo.APIKey`
   */
  public func login(completion: (Result<LoginResult?, ClientError>) -> Void) {
    switch loginInfo {
    case .APIKey(let apiKey):
      credentials = Credentials(apiKey: apiKey)
      completion(.Success(nil))
    case .Password(let email, let password):
      login(email, password: password) { result in
        switch result {
        case .Success(let value):
          completion(.Success(value))
        case .Failure(let error):
          completion(.Failure(error))
        }
      }
    }
  }
  
  private func login(email: String, password: String, completion: (Result<LoginResult, ClientError>) -> Void) {
    let emailParam = AnyRequestParam(key: "email", value: email)
    let passwordParam = AnyRequestParam(key: "pass", value: password)
    let request = NSURLRequest.create(subdomain: subdomain, function: .Login, params: [emailParam, passwordParam])
    
    execute(request, completion: completion)
  }
  
  public struct LoginResult {
    public let email: String
    public let username: String
    public let realName: String
    public let companyName: String
    public let timezone: String
    public let apiKey: String
  }
}

extension Client.LoginResult: APIResult {
  public init?(jsonObject: AnyObject) {
    guard let json = jsonObject as? Dictionary<String, AnyObject> else { return nil }
    
    guard let
      email = json["email"] as? String,
      username = json["username"] as? String,
      realName = json["realname"] as? String,
      companyName = json["companyname"] as? String,
      timezone = json["timezone"] as? String,
      apiKey = json["apikey"] as? String
      else { return nil }
    
    self.email = email
    self.username = username
    self.realName = realName
    self.companyName = companyName
    self.timezone = timezone
    self.apiKey = apiKey
  }
}

