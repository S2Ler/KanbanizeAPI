
import Foundation

public extension Client {
  public final class SimpleExecutor: Executor {
     public func execute(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
      let session = URLSession.shared
      let task = session.dataTask(with: request, completionHandler: completion)
      task.resume()
    }
  }
}
