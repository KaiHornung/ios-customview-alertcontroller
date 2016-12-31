//
//  ViewController.swift
//  CustomViewAlertControllerSample
//
//  Created by Kai Hornung on 31.12.16.
//  Copyright © 2016 kh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet var alertTitleTextField: UITextField!
  @IBOutlet var alertMessageTextField: UITextField!
  @IBOutlet var showOKActionSwitch: UISwitch!
  @IBOutlet var viewHeightSlider: UISlider!
  @IBOutlet var showCancelActionSwitch: UISwitch!
  @IBOutlet var presentButton: UIButton!
  
  //MARK: Properties
  private var alertStyle: UIAlertControllerStyle = .alert
  private var position: CustomViewAlertController.CustomViewPosition = .top
  
  //MARK: IBActions
  @IBAction func alertStyleChanged(_ sender: UISegmentedControl) {
    alertStyle = sender.selectedSegmentIndex == 0 ? .alert : .actionSheet
  }
  
  @IBAction func positionChanged(_ sender: UISegmentedControl) {
    position = sender.selectedSegmentIndex == 0 ? .top : .bottom
  }
  
  @IBAction func presentAlertController(_ sender: Any) {
    // create alert. Always use at least one label, either title or message must not be nil
    let alert = CustomViewAlertController(title: alertTitleTextField.text ?? "",
                                          message: alertMessageTextField.text,
                                          preferredStyle: alertStyle)
    
    // set position of custom view
    alert.customViewPosition = position
    
    // create custom view
    let view = UIView(frame: .zero)
    NSLayoutConstraint.activate([
      view.heightAnchor.constraint(equalToConstant: CGFloat(viewHeightSlider.value))
      ])
    view.backgroundColor = view.tintColor
    alert.customView = view
    
    // add ok button
    if showOKActionSwitch.isOn {
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    // add cancel button
    if showCancelActionSwitch.isOn {
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    // prepare popover presentation controller for iPad
    alert.popoverPresentationController?.sourceView = presentButton.superview
    alert.popoverPresentationController?.sourceRect = presentButton.frame
    alert.popoverPresentationController?.permittedArrowDirections = [.down]
    
    // present alert
    present(alert, animated: true) {
      if alert.actions.count == 0 {
        // Dismiss after two seconds, if no button is shown
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          alert.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
}

// MARK: - Text field delegate conformance
extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
