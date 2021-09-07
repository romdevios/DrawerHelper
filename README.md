# DrawerHelper

The tool to help you control the behavior of the drawer view.

## Contents
- [Requirements](#requirements)
- [Installation](#installation)
- [Example](#example)
- [Usage](#usage)
    


## Requirements

- iOS 9.0+ / tvOS 9.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 12+ is required to build DrawerHelper using Swift Package Manager.

To integrate DrawerHelper into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/romdevios/DrawerHelper.git", .upToNextMajor(from: "0.1.0"))
]
```

Or add dependency manually in Xcode. File -> Swift Packages -> Add Package Dependency... then enter the package URL 'https://github.com/romdevios/DrawerHelper.git' and click Next button.


### CocoaPods

[CocoaPods](#https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:
```
$ gem install cocoapods
```
To integrate **DrawerHelper** into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
  pod 'DrawerHelper'
end
```
Then, run the following command:
```
$ pod install --repo-update
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate DrawerHelper into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "romdevios/DrawerHelper"
```

Run `$ carthage update --use-xcframeworks` and drag the built `.xcframework` bundles from `Carthage/Build` into the "Frameworks and Libraries" section of your application’s Xcode project. If you are using Carthage for an application, select "Embed & Sign", otherwise "Do Not Embed".


<br />

## Example

<details>
   <summary>Setup ViewController</summary>
   
   ```swift
   import LayoutChain

   class ViewController: UIViewController {

      let drawerView = UIView()
      var helper: DrawerHelper!
      var panGesture: UIPanGestureRecognizer!

      override func viewDidLoad() {
         super.viewDidLoad()

         drawerView.backgroundColor = .systemTeal
         view.addSubview(drawerView)
         
         NSLayoutConstraint.activate([
            drawerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            drawerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            drawerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
         ])
         
         // ...
      }

   }
   ```
</details>

```swift
let manipulatingConstraint = drawerView.topAnchor.constraint(equalTo: view.bottomAnchor)
manipulatingConstraint.isActive = true
let maxOffset = view.bounds.height - 100 - view.safeAreaInsets.bottom

helper = .init(receiver: .constraint(manipulatingConstraint, inverted: true), axis: .vertical, initialValue: 32, maximumOffset: maxOffset)

panGesture = UIPanGestureRecognizer(target: helper.panGestureHandler, action: #selector(DrawerPanGestureHandler.handleDrawerPanGesture))
drawerView.addGestureRecognizer(panGesture)
panGesture.delegate = helper.panGestureHandler
```

<br />

## Usage

To init helper you should provide value receiver that will be called with updates for drawer position. You can use one of built in receivers or create your own. The first one controls constraint constant and another changes transform translate of drawerView. 


There are two options to control drawer position. First as in example using UIPanGestureRecognizer. Second is using scrollView delegate. You can implement own delegate and recall corresponding methods in `helper.scrollViewHandler` or just set that handler as delegate of tableView.

```swift
tableView.delegate = helper.scrollViewHandler
```

