# Quur-swift

![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Quur-swift makes it easy to deal with QR Code data in Swift.

## Usage

Generate a QR Code from a given string.

```swift
let code = QuuR.Code(from: "https://github.com/", quality: .high)
let imageView = UIImageView(image: code.image)
view.addSubview(imageView)
```

## TODO

- [x] Generate a QR Code
- [ ] Read a QR Code
