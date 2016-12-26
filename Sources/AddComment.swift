//
//  AddComment.swift
//  KanbanizeAPI
//
//  Created by Alexander Belyavskiy on 4/19/16.
//  Copyright © 2016 Alexander Belyavskiy. All rights reserved.
//

import Foundation

public extension Client.RequestBuilder {
  public func addComment(_ comment: String,
                         taskID: TaskID) throws -> URLRequest {
    guard let credentials = self.credentials else { throw Client.Error.notLoggedIn }

    let request = URLRequest.create(subdomain: subdomain,
                                    credentials: credentials,
                                    function: .addComment,
                                    params: [AnyRequestParam(key: "comment", value: comment), taskID])

    return request
  }
}

public extension Client {
  public func addComment(_ comment: String,
                         taskID: TaskID,
                         completion: @escaping (Result<AddCommentResult, ClientError>) -> Void) throws
  {
    let request = try requestBuilder().addComment(comment, taskID: taskID)
    execute(request, completion: completion)
  }

  public struct AddCommentResult {
    public let id: String
    public let author: String
    public let date: Date
  }
}

extension Client.AddCommentResult: APIResult {
  public init?(jsonObject: AnyObject) {
    guard let json = jsonObject as? Dictionary<String, AnyObject> else { return nil }
    guard
      let idObj = json["id"],
      let author = json["author"] as? String
      //      date = json["date"] as? String
      else { return nil }

    self.id = String(describing: idObj)
    self.author = author
    self.date = Date()//TODO: parse date
  }
}
