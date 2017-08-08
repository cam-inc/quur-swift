# QuuR-swift

![Platform](https://img.shields.io/badge/platforms-iOS%208.0+-333333.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

QuuR-swift makes it easy to deal with QR Code data in Swift.

![](https://user-images.githubusercontent.com/2027132/28912873-f946e77e-7870-11e7-9ed5-a7121a6f6e92.png)

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

![capture of Info.plist](https://user-images.githubusercontent.com/2027132/29057738-8a3f3c70-7c47-11e7-8220-2508746c2da2.png)

### Generate a QR Code from a given string.

Standard QRCode

```swift
let code = QuuR.Code(from: "https://github.com/", quality: .high)
let imageView = UIImageView(image: code.image)
```

Colored QRCode

```swift
var code = QuuR.Code(from: "https://github.com/", quality: .high)
code.backgroundColor = CIColor(red: 0.0, green: 1.0, blue: 0.5)
code.color = CIColor(red: 0, green: 0, blue: 0)
let imageView = UIImageView(image: code.image)
```

Design QRCode

When you set true to isAutoAdjustingColor, QuuR.Code will detect the primary color of the centerImage and use it to the foreground color of the QRCode.

```swift
var code = QuuR.Code(from: "https://github.com/", quality: .high)
code.errorCorrectionLevel = .high
code.centerImage = UIImage(named: "SomeImage")
code.isAutoAdjustingColor = true
let imageView = UIImageView(image: code.image)
```

### Read from UIImage

`StaticReader.read` will return an optional array of strings `[String]?`

```swift
let texts = QuuR.StaticReader.read(image: SomeQRCodeImage)
```

### Read QRCode from Camera input

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
