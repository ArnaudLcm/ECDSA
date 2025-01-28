import BigInt
import Crypto

public struct PublicKey {

  public var eccPoint: ECCPoint

  public var generatorPoint: ECCPoint

  init(point: ECCPoint, generator: ECCPoint) {
    self.eccPoint = point
    self.generatorPoint = generator
  }

  public func verifySignature(message: String, k: BigInt, Q: ECCPoint) throws -> Bool {
    guard let messageData = message.data(using: .utf8) else {
      throw ECDSAError.invalidMessage("Message cannot be converted to data.")
    }
    let hash = SHA256.hash(data: messageData)

    let hashedMessage = BigInt(hash.compactMap { String(format: "%02x", $0) }.joined(), radix: 16)!


    return Q == k*(hashedMessage*self.generatorPoint + self.eccPoint)
  }

}
