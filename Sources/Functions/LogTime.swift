
import Foundation

public extension Client.RequestBuilder {
  public func logTime(loggedTime: LoggedTime,
                      taskID: TaskID,
                      description: Description? = nil) throws -> NSURLRequest {
    guard let credentials = self.credentials else { throw Client.Error.NotLoggedIn }

    let request = NSURLRequest.create(subdomain: subdomain,
                                      credentials: credentials,
                                      function: .LogTime,
                                      params: [loggedTime, taskID])
    
    return request
  }
}

public extension Client {
  public func logTime(
    loggedTime: LoggedTime,
    taskID: TaskID,
    description: Description? = nil,
    completion: (Result<LogTimeResult, ClientError>) -> Void) throws
  {
    let request = try requestBuilder().logTime(loggedTime, taskID: taskID, description: description)
    execute(request, completion: completion)
  }
  
  public struct LogTimeResult {
    public let id: String
    public let taskID: TaskID
    public let author: String
    public let details: String
    public let loggedTime: LoggedTime
    public let isSubTask: Bool
    public let title: String
    public let comment: String
    public let originData: NSDate
  }
}

extension Client.LogTimeResult: APIResult {
  public init?(jsonObject: AnyObject) {
    guard let json = jsonObject as? Dictionary<String, AnyObject> else { return nil }
    
    guard let
      id = json["id"] as? String,
      taskID = json["taskid"] as? String,
      author = json["author"] as? String,
      details = json["details"] as? String,
      loggedTime = json["loggedtime"] as? Double,
      isSubTask = json["issubtask"] as? Bool,
      title = json["title"] as? String,
      comment = json["comment"] as? String//,
    //      originData = json["origindate"] as? String
      else { return nil }
    
    self.id = id
    self.taskID = TaskID(taskID)
    self.author = author
    self.details = details
    self.loggedTime = LoggedTime(hours: loggedTime)
    self.isSubTask = isSubTask
    self.title = title
    self.comment = comment
    self.originData = NSDate()//TODO: parse date
  }
}