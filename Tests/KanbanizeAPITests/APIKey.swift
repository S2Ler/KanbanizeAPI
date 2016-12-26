import Foundation

internal let subdomain = env("subdomain")
internal let apiKey = env("apiKey")
internal let validEmail = env("validEmail")
internal let validPassword = env("validPassword")

internal let testTaskID = env("testTaskID")

private func env(_ name: String) -> String {
  return ProcessInfo().environment[name]!
}
