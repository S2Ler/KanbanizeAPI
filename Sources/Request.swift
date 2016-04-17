
import Foundation

internal extension NSURLRequest {
  static func create(subdomain subdomain: String,
                               credentials: Client.Credentials,
                               function: Function,
                               params: [RequestParam]) -> NSMutableURLRequest {
    let request = create(subdomain: subdomain, function: function, params: params)
    request.addValue(credentials.apiKey, forHTTPHeaderField: "apikey")
    request.HTTPMethod = "POST"
    return request
  }
  
  static func create(subdomain subdomain: String,
                               function: Function,
                               params: [RequestParam]) -> NSMutableURLRequest {
    let url = NSURL(subdomain: subdomain, function: function)
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.HTTPBody = jsonData(params)
    return request
  }
}

internal protocol RequestParam {
  var key: String {get}
  var value: String {get}
}

private func jsonData(params: [RequestParam]) -> NSData {
  var json: [String: String] = [:]
  params.forEach { json[$0.key] = $0.value }
  let jsonData = try! NSJSONSerialization.dataWithJSONObject(json,
                                                             options: NSJSONWritingOptions.init(rawValue: 0))
  return jsonData
}
