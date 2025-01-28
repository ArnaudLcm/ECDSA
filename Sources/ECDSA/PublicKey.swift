public struct PublicKey {

    var eccPoint: ECCPoint;

    init(point: ECCPoint) {
        self.eccPoint = point
    }

}