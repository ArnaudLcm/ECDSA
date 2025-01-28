// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ECDSA",
  products: [
    .library(
      name: "ECDSA",
      targets: ["ECDSA"])
  ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt", from: "5.0.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0"),
  ],
  targets: [
    .target(
      name: "ECDSA",
      dependencies: [
        .product(name: "BigInt", package: "BigInt"),
        .product(name: "Crypto", package: "swift-crypto"),
      ]),
    .testTarget(
      name: "ECDSATests",
      dependencies: ["ECDSA"]
    ),
  ]
)
