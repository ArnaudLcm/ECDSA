public struct PublicKey {

    public var eccPoint: ECCPoint;

    init(point: ECCPoint) {
        self.eccPoint = point
    }

}