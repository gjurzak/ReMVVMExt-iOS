// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReMVVMExt",
    platforms: [.iOS(.v9)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ReMVVMExt",
            targets: ["ReMVVMExt"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/dgrzeszczak/Loaders",
            .branch("feature/ViewModelDriven")
        ),
        .package(
            url: "https://github.com/dgrzeszczak/ReMVVM",
            .branch("feature/packageManager")
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift",
            .upToNextMajor(from: "5.0.1")
        ),
        .package(url: "https://github.com/dgrzeszczak/MVVM", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ReMVVMExt",
            dependencies: ["MVVM", "Loaders", "ReMVVM", "RxSwift", "RxCocoa", "RxRelay"],
            path: "ReMVVMExt/Sources",
            exclude: [])
    ]
)
