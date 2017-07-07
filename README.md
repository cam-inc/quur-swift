# Quur-swift

![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Quur-swift makes it easy to deal with QR Code data in Swift.

## Requirements

- iOS 8.0+
- Xcode 8

## Carthage

You can use [Carthage](https://github.com/Carthage/Carthage) to install `Quur-swift` by adding it to your `Cartfile`:

```
github "cam-inc/quur-swift"
```

Don't forget to add `--use-ssh` flag to Carthage command.

## Usage

In iOS10+, you will need first to reasoning about the camera use. For that you'll need to add the **Privacy - Camera Usage Description** *(NSCameraUsageDescription)* field in your Info.plist:

![capture of Info.plist](./assets/camera-usage.png)
### Generate a QR Code from a given string.

```swift
let code = QuuR.Code(from: "https://github.com/", quality: .high)
let imageView = UIImageView(image: code.image)
view.addSubview(imageView)
```

### Read a text from a QR Code.

```swift
class ViewController: UIViewController {
    let reader = QuuR.Reader()

    override func viewDidLoad() {

        super.viewDidLoad()

        // Set a desired frame size
        reader.frame = view.frame

        // Called when detected a qr code
        reader.delegate = self

        view.addSubview(reader)
        reader.startDetection()
    }
}

extension ViewController: ReaderDidDetectQRCode {

    public func reader(_ reader: Reader, didDetect text: String) {
        print(text)
        reader.stopDetection()
    }
}
```
