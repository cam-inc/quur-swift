# QuuR-swift

![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

QuuR-swift makes it easy to deal with QR Code data in Swift.

## Requirements

- iOS 8.0+
- Xcode 8

## Carthage

You can use [Carthage](https://github.com/Carthage/Carthage) to install `QuuR-swift` by adding it to your `Cartfile`:

```
github "cam-inc/QuuR-swift"
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
    @IBOutlet weak var reader: Reader!

    override func viewDidLoad() {
        super.viewDidLoad()
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

### Use QuuR.Reader with Storyboard

1. Drag and drop a UIView into the desired place.
1. Show Identity Inspector.
1. Set Class to `Reader` and Module to `QuuR`

![](https://user-images.githubusercontent.com/2027132/28710960-e9721df0-73c0-11e7-9f26-7522f38e2a61.png)

#### IBInspectable properties

1. **isZoomable** Enable to zoom a video input by pinching a screen.
1. **maxZoomScale** Set it to a positive CGFloat value.

![](https://user-images.githubusercontent.com/2027132/28774239-ab21e3c8-7627-11e7-97c7-4e1d2255b141.png)

#### Delegate

Delegate property also settable from Storyboard by right-clicking a Reader view.

![](https://user-images.githubusercontent.com/2027132/28774494-a4b9fb00-7628-11e7-9687-4423d59dd7ec.png)
