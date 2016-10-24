
import Foundation

public final class Client {
  public let subdomain: String
  internal let loginInfo: LoginInfo
  fileprivate var _credentials: Credentials?
  fileprivate(set) internal var credentials: Credentials? {
    get {
      if case LoginInfo.apiKey(let apiKey) = loginInfo {
        _credentials = Credentials(apiKey: apiKey)
      }
      return _credentials
    }
    set {
      _credentials = newValue
    }
  }
  internal let executor: Executor

  public init(subdomain: String, loginInfo: LoginInfo, executor: Executor = SimpleExecutor()) {
    self.subdomain = subdomain
    self.loginInfo = loginInfo
    self.executor = executor
  }

  public enum LoginInfo {
    case apiKey(String)
    case password(email: String, password: String)
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

  public enum Error: Swift.Error {
    case notLoggedIn
  }
}

public extension Client {
  public struct RequestBuilder {
    fileprivate let client: Client
    fileprivate init(client: Client) {
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
  func execute(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Swift.Error?) -> Void)
}

internal extension Client {
  func execute<ResultType: APIResult>(_ request: URLRequest, completion: @escaping (Result<ResultType, ClientError>) -> Void) {
    executor.execute(request) { (data: Data?, response: URLResponse?, error: Swift.Error?) in

      if let data = data {
        do {
          let parsedResult: ResultType = try DataParser.parse(data)
          completion(.success(parsedResult))
        }
        catch let clientError as ClientError {
          completion(.failure(clientError))
        }
        catch {
          completion(.failure(.jsonMallformed))
        }
      }
      else {
        completion(.failure(.networkError(error!)))
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
  public func login(_ completion: @escaping (Result<LoginResult?, ClientError>) -> Void) {
    switch loginInfo {
    case .apiKey(_):
      //API Key login info considered as automatically logged in
      completion(.success(nil))
    case .password(let email, let password):
      login(email, password: password) { [weak self] result in
        switch result {
        case .success(let loginResult):
          self?.credentials = Credentials(apiKey: loginResult.apiKey)
          completion(.success(loginResult))
        case .failure(let error):
          self?.credentials = nil
          completion(.failure(error))
        }
      }
    }
  }

  fileprivate func login(apiKey: String) {
    credentials = Credentials(apiKey: apiKey)
  }

  fileprivate func login(_ email: String,
                         password: String,
                         completion: @escaping (Result<LoginResult, ClientError>) -> Void) {
    let emailParam = AnyRequestParam(key: "email", value: email)
    let passwordParam = AnyRequestParam(key: "pass", value: password)
    let request = URLRequest.create(subdomain: subdomain, function: .login, params: [emailParam, passwordParam])

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
      let username = json["username"] as? String,
      let realName = json["realname"] as? String,
      let companyName = json["companyname"] as? String,
      let timezone = json["timezone"] as? String,
      let apiKey = json["apikey"] as? String
      else { return nil }

    self.email = email
    self.username = username
    self.realName = realName
    self.companyName = companyName
    self.timezone = timezone
    self.apiKey = apiKey
  }
}
