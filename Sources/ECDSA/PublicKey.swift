import BigInt
import Crypto

public struct PublicKey {

  public var eccPoint: ECCPoint

  public var generatorPoint: ECCPoint

  private var order: BigInt

  init(point: ECCPoint, generator: ECCPoint, order: BigInt) {
    self.eccPoint = point
    self.generatorPoint = generator
    self.order = order
  }

  public func verifySignature(message: String, k: BigInt, Q: ECCPoint, r: BigInt) throws -> Bool {
    guard let messageData = message.data(using: .utf8) else {
      throw ECDSAError.invalidMessage("Message cannot be converted to data.")
    }
    let hash = SHA256.hash(data: messageData)

    let hashedMessage = BigInt(hash.compactMap { String(format: "%02x", $0) }.joined(), radix: 16)!

    let r = Q.x!.value % self.order

    return Q == k*(hashedMessage*self.generatorPoint + r*self.eccPoint)
  }

}
