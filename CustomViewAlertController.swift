/*
 * CustomViewAlertController
 *
 * Copyright (c) 2016 Kai Hornung
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import UIKit

/**
 CustomViewAlertController extends `UIAlertController` with the ability to display a custom view above or below (default) the alert controller's text labels.
 
 The custom view needs to be able to determine its actual height using the `systemLayoutSizeFitting`-method of UIView after being extended with a width-constraint by the CustomViewAlertController.
 
 For views with a fixed height, you therefore might need to add a height-constraint before presenting the CustomViewAlertController.
 
 Please note that adding text fields to the CustomViewAlertController is not possible using the `UIAlertController`'s `addTextField`-method. Instead, the text fields need to be added to the custom view.
 
 In order for custom views to be displayed properly, you need to provide either a title or a message to the alert controllers initializer. To display *only* the custom view in the alert, you need to pass an empty title string ("") to the initializer:
 
     let alertController = CustomViewAlertController(title: "", message: nil, preferredStyle: .alert)
 */
class CustomViewAlertController: UIAlertController {
  /// The custom view position indicates if the custom view should be displayed above or below the alert labels.
  enum CustomViewPosition {
    /// Present the custom view above the labels.
    case top
    /// Present the custom view below the labels.
    case bottom
  }
  
  /// A custom view to be displayed in the alert.
  var customView: UIView?
  /// The position of the custom view.
  var customViewPosition: CustomViewPosition = .bottom

  /// The view containing the title label, the message label and the custom view.
  private var containerView: UIView?
  /// An indicator whether or not the custom view constraints are already created.
  private var customViewPrepared = false
  /// An indicator whether or not there is a title or message shown.
  private var bothLabelsEmpty = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let customView = customView else {
      // nothing to do if no custom view is set
      return
    }
    
    // find labels in view hierarchy
    let labels = view.allSubviews.flatMap { $0 as? UILabel }
    
    // find out if both labels are empty (to display only custom views)
    bothLabelsEmpty = !labels.contains(where: { !($0.text?.isEmpty ?? true) })
    
    // set container view (the direct super-views of the title and message label)
    containerView   = labels.first?.superview
    
    guard let containerView = containerView else {
      // no labels -> no way to find the container view.
      fatalError("MyAlertController: Instead of a nil-title, please use the empty string \"\"")
    }
    
    // disable autoresizing mask constraints
    customView.translatesAutoresizingMaskIntoConstraints = false
    
    // add custom view to container view
    containerView.addSubview(customView)
    
    // prepare horizontal constraints on customView
    NSLayoutConstraint.activate([
      customView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      customView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
      ])
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    // prepare custom view
    prepareCustomViewIfNeccessary()
  }
  
  override func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
    // UIAlertController text fields are not supported when using a CustomViewAlertController
    fatalError("MyAlertController: Please use the custom view to add text fields")
  }
  
  /// This methods prepares the neccessary constraints for displaying the custom view correctly
  private func prepareCustomViewIfNeccessary() {
    guard !customViewPrepared,
      let customView = customView,
      let containerView = containerView else {
        return
    }
    
    // compute the height of the custom view
    let customViewHeight = customView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    
    // create a height constraint for the total container view height
    let heightConstraint: NSLayoutConstraint
    if bothLabelsEmpty {
      // if no text is shown, take the custom view height only
      heightConstraint = containerView.heightAnchor.constraint(equalToConstant: customViewHeight)
    } else {
      // if there is text shown, take the custom view height plus the original height
      let originalContainerHeight = containerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
      heightConstraint = containerView.heightAnchor.constraint(equalToConstant: originalContainerHeight + customViewHeight)
    }
    
    // create a position constraint for the vertical position of the custom view inside the container view
    let positionConstraint: NSLayoutConstraint
    switch customViewPosition {
    case .top:
      // above the labels: deactivate the constraint connecting the container top and the first label
      NSLayoutConstraint.deactivate(containerView.topAnchorConstraints)
      // then connect the container top to the custom view top
      positionConstraint = customView.topAnchor.constraint(equalTo: containerView.topAnchor)
    case .bottom:
      // below the labels: deactivate the constraint connecting the container bottom and the last label
      NSLayoutConstraint.deactivate(containerView.bottomAnchorConstraints)
      // then connect the container top to the custom view top
      positionConstraint = customView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    }
    
    // activate the new vertical constraints
    NSLayoutConstraint.activate([heightConstraint, positionConstraint])
    
    // set the view prepared property
    customViewPrepared = true
  }
}

//MARK: - Helper methods for UIView
private extension UIView {
  /// All constraints with the view's top anchor.
  var topAnchorConstraints: [NSLayoutConstraint] {
    return self.constraints.filter { constraint in
      return constraint.firstAnchor == self.topAnchor || constraint.secondAnchor == self.topAnchor
    }
  }
  
  /// All constraints with the view's bottom anchor.
  var bottomAnchorConstraints: [NSLayoutConstraint] {
    return self.constraints.filter { constraint in
      return constraint.firstAnchor == self.bottomAnchor || constraint.secondAnchor == self.bottomAnchor
    }
  }
  
  /// All subviews (recursively).
  var allSubviews: [UIView] {
    return subviews.reduce([self], { $0 + $1.allSubviews })
  }
}
