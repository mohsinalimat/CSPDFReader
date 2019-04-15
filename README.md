# CSPDFReader

[![CI Status](https://img.shields.io/travis/WeiRuJian/CSPDFReader.svg?style=flat)](https://travis-ci.org/WeiRuJian/CSPDFReader)
[![Version](https://img.shields.io/cocoapods/v/CSPDFReader.svg?style=flat)](https://cocoapods.org/pods/CSPDFReader)
[![License](https://img.shields.io/cocoapods/l/CSPDFReader.svg?style=flat)](https://cocoapods.org/pods/CSPDFReader)
[![Platform](https://img.shields.io/cocoapods/p/CSPDFReader.svg?style=flat)](https://cocoapods.org/pods/CSPDFReader)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CSPDFReader is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CSPDFReader'
```

## Using
```Swift
let url = URL(fileURLWithPath: Bundle.main.path(forResource: "图解HTTP", ofType: "pdf")!)
guard let reader = CSPDFReader(url: url, constant: 300) else { return }
print("totalPage: \(reader.pageCount)")
print("fileName: \(reader.fileName)")
guard let images = reader.allPageImages() else { print("No find image"); return }
```

## Author

Choshim丶Wy, 824041965@qq.com

## License

CSPDFReader is available under the MIT license. See the LICENSE file for more info.
