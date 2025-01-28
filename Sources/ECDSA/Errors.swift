public struct ECDSAError: Error, Hashable {
  private var content: Content

  fileprivate init(content: Content) {
    self.content = content
  }

  public static func invalidFiniteElement(_ context: String) -> ECDSAError {
    Self.init(content: .invalidFiniteElement(context: context))
  }

  public static func invalidCurveDefinition(_ context: String) -> ECDSAError {
    Self.init(content: .invalidCurveDefinition(context: context))
  }

  public static func invalidOperation(_ context: String) -> ECDSAError {
    Self.init(content: .invalidOperation(context: context))
  }

  public static func invalidMessage(_ reason: String) -> ECDSAError {
    Self.init(content: .invalidMessage(reason: reason))
  }
}

extension ECDSAError {
  enum Content: Hashable, Sendable {
    case invalidFiniteElement(context: String)
    case invalidCurveDefinition(context: String)
    case invalidOperation(context: String)
    case invalidMessage(reason: String)
  }
}
