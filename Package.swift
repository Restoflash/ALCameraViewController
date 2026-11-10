// swift-tools-version:5.5
// Swift Package Manager manifest of the Restoflash fork, next to the podspec: same sources and resources.

import PackageDescription

let package = Package(
    name: "ALCameraViewController",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ALCameraViewController", targets: ["ALCameraViewController"]),
    ],
    targets: [
        .target(
            name: "ALCameraViewController",
            path: "ALCameraViewController",
            exclude: [".DS_Store"],
            resources: [
                .process("CameraViewAssets.xcassets"),
                .process("ViewController/ConfirmViewController.xib"),
                .copy("CameraView.strings"),
            ]
        ),
    ]
)
