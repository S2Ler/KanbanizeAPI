
import Foundation

internal extension URLRequest {
  static func create(subdomain: String,
                     credentials: Client.Credentials,
                     function: Function,
                     params: [RequestParam]) -> URLRequest {
    var request = create(subdomain: subdomain, function: function, params: params)
    request.addValue(credentials.apiKey, forHTTPHeaderField: "apikey")
    request.httpMethod = "POST"
    return request
  }

  static func create(subdomain: String,
                     function: Function,
                     params: [RequestParam]) -> URLRequest {
    let url = URL(subdomain: subdomain, function: function)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonData(params)
    return request
  }
}

internal protocol RequestParam {
  var key: String {get}
  var value: String {get}
}

private func jsonData(_ params: [RequestParam]) -> Data {
  var json: [String: String] = [:]
  params.forEach { json[$0.key] = $0.value }
  let jsonData = try! JSONSerialization.data(withJSONObject: json,
                                             options: JSONSerialization.WritingOptions.init(rawValue: 0))
  return jsonData
}
