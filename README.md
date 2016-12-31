CustomViewAlertController for iOS
=====
The CustomViewAlertController class provides a simple-to-use extension of the UIAlertController functionality with the ability to present arbitrary view inside the alert.

The alert controller is written in Swift 3 and has been testen for iOS 10 and above.

Usage
-----
To use a custom view in an alert, you simply use add the `CustomViewAlertController.swift` file to your project and use the  `CustomViewAlertController` class to instantiate alerts instead of UIKit's `UIAlertController`.

```swift
let alert = CustomViewAlertController(title: "Your alert title",
                                      message: "Your alert message",
                                      preferredStyle: .alert)
```

You can choose between two positions for the custom view in the alert, `top` and `bottom`. The first one locates the view above the alert's title and message labels, the latter right above the buttons for the alert actions. The default position is `top`, i.e. above the labels.

```swift
alert.customViewPosition = .bottom
```

The custom view needs to be able to infer its height depending on a width constraint which is added by the alert controller before presenting the alert. Therefore, if the custom view does not provide an intrinsic size, you might need to add a height constraint manually before setting the view as the alert controller's `customView` property:

```swift
let view = UIView(frame: .zero)
view.backgroundColor = view.tintColor

NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: 100.0)])
alert.customView = view
```

You can add alert actions the same way you do with `UIAlertController`:
```swift
alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
```

The configured alert controller is then being presented using `UIViewController`'s `present(_:animated:completion:)` method.
```swift
present(alert, animated: true, completion: nil)
```

The alert then looks like this:
TODO

License
-----
This code is released unter the MIT license.
