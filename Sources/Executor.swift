
import Foundation

public extension Client {
  public class SimpleExecutor: Executor {
    public func execute(request: NSURLRequest, completion: (NSData?, NSURLResponse?, NSError?) -> Void) {
      let session = NSURLSession.sharedSession()
      let task = session.dataTaskWithRequest(request, completionHandler: completion)
      task.resume()
    }
  }
}