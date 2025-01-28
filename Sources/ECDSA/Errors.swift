public struct ECDSAError: Error, Hashable {
    private var content: Content

    fileprivate init(content: Content) {
        self.content = content
    }

    public static func invalidFiniteElement(_ context: String) -> ECDSAError {
        Self.init(content: .invalidFiniteElement(context: context))
    }
}

extension ECDSAError {
    enum Content: Hashable, Sendable {
        case invalidFiniteElement(context: String)
    }
}