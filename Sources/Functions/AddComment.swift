//
//  AddComment.swift
//  KanbanizeAPI
//
//  Created by Alexander Belyavskiy on 4/19/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

public extension Client.RequestBuilder {
  public func addComment(comment: String,
                         taskID: TaskID) throws -> NSURLRequest {
    guard let credentials = self.credentials else { throw Client.Error.NotLoggedIn }
    
    let request = NSURLRequest.create(subdomain: subdomain,
                                      credentials: credentials,
                                      function: .AddComment,
                                      params: [AnyRequestParam(key: "comment", value: comment), taskID])
    
    return request
  }
}

public extension Client {
  public func addComment(comment: String,
                         taskID: TaskID,
                         completion: (Result<AddCommentResult, ClientError>) -> Void) throws
  {
    let request = try requestBuilder().addComment(comment, taskID: taskID)
    execute(request, completion: completion)
  }
  
  public struct AddCommentResult {
    public let id: String
    public let author: String
    public let date: NSDate
  }
}

extension Client.AddCommentResult: APIResult {
  public init?(jsonObject: AnyObject) {
    guard let json = jsonObject as? Dictionary<String, AnyObject> else { return nil }
    guard
      let idObj = json["id"],
      author = json["author"] as? String
      //      date = json["date"] as? String
      else { return nil }
    
    self.id = String(idObj)
    self.author = author
    self.date = NSDate()//TODO: parse date
  }
}