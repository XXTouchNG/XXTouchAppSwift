//
//  NewScriptViewController.swift
//  OneFuncApp
//
//  Created by mcy on 16/5/31.
//  Copyright © 2016年 mcy. All rights reserved.
//

import UIKit

protocol NewScriptViewControllerDelegate: NSObjectProtocol {
  func reloadScriptList()
}

class NewScriptViewController: UIViewController {
  private let textView = UITextView()
  private let placeHolderLabel = UILabel()
  weak var delegate: NewScriptViewControllerDelegate?
  private let newNameView = NewNameView()
  private let blurView = JCRBlurView()
  private let animationDuration = 0.5
  private var data = ""
  private var extensionName = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    makeConstriants()
    setupAction()
    bind()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    //    newFileName.becomeFirstResponder()
  }
  
  private func setupUI() {
    view.backgroundColor = UIColor.whiteColor()
    navigationItem.title = "新建文件"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: #selector(next))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
    
    placeHolderLabel.text = "点我开始写代码.."
    placeHolderLabel.textColor = UIColor.lightGrayColor()
    
    textView.backgroundColor = UIColor(rgb: 0x434343)
    textView.textColor = UIColor.whiteColor()
    textView.delegate = self
    textView.addSubview(placeHolderLabel)
    
    newNameView.hidden = true
    blurView.hidden = true
    blurView.alpha = 0
    newNameView.layer.cornerRadius = 5
    
    newNameView.layer.shadowOffset = CGSize(width: 0, height: 3)
    newNameView.layer.shadowRadius = 3.0
    newNameView.layer.shadowColor = UIColor.blackColor().CGColor
    newNameView.layer.shadowOpacity = 0.4
    
    view.addSubview(textView)
    view.addSubview(blurView)
    view.addSubview(newNameView)
  }
  
  private func makeConstriants() {
    textView.snp_makeConstraints { (make) in
      make.edges.equalTo(view)
    }
    
    placeHolderLabel.snp_makeConstraints { (make) in
      make.top.leading.trailing.equalTo(textView).inset(10)
    }
    
    newNameView.snp_makeConstraints{ (make) in
      make.center.equalTo(view)
      make.leading.trailing.equalTo(view).inset(Sizer.valueForPhone(inch_3_5: 20, inch_4_0: 20, inch_4_7: 42, inch_5_5: 62))
      make.height.equalTo(80)
    }
    
    blurView.snp_makeConstraints { (make) in
      make.edges.equalTo(view)
    }
  }
  
  private func setupAction() {
    newNameView.submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
    blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blurTap)))
    newNameView.luaButton.addTarget(self, action: #selector(luaClick(_:)), forControlEvents: .TouchUpInside)
    newNameView.txtButton.addTarget(self, action: #selector(txtClick(_:)), forControlEvents: .TouchUpInside)
  }
  
  private func bind() {
    extensionName = newNameView.luaButton.titleLabel?.text ?? ".lua"
  }
  
  @objc private func luaClick(button: UIButton) {
    buttonCustomStatus(selectedButton: button, unselectedButton: newNameView.txtButton)
    extensionName = button.titleLabel!.text!
  }
  
  @objc private func txtClick(button: UIButton) {
    buttonCustomStatus(selectedButton: button, unselectedButton: newNameView.luaButton)
    extensionName = button.titleLabel!.text!
  }
  
  private func buttonCustomStatus(selectedButton selectedButton: UIButton, unselectedButton: UIButton) {
    selectedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    selectedButton.backgroundColor = ThemeManager.Theme.redBackgroundColor
    unselectedButton.setTitleColor(ThemeManager.Theme.tintColor, forState: .Normal)
    unselectedButton.backgroundColor = ThemeManager.Theme.separatorColor
  }
  
  @objc private func submit() {
    newNameView.newNameTextField.resignFirstResponder()
    guard newNameView.newNameTextField.text?.characters.count != 0 else {
      alert(title: Constants.Text.prompt, message: "文件名不能为空", delegate: nil, cancelButtonTitle: Constants.Text.ok)
      return
    }
    addScript()
  }
  
  @objc private func blurTap() {
    if !newNameView.newNameTextField.resignFirstResponder() {
      closeNewNameViewAnimator()
    } else {
      newNameView.newNameTextField.resignFirstResponder()
    }
  }
  
  private func closeNewNameViewAnimator() {
    navigationController?.tabBarController?.tabBar.hidden = false
    navigationController?.setNavigationBarHidden(false, animated: true)
    UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: [], animations: {
      self.blurView.alpha = 0
      self.newNameView.alpha = 0
      }, completion: { (_) in
        self.newNameView.hidden = true
        self.blurView.hidden = true
        self.newNameView.transform = CGAffineTransformIdentity
    })
  }
  
  @objc private func next() {
    if textView.text.characters.count == 0 {
      self.data = Constants.Text.startScript
    } else {
      self.data = textView.text
    }
    navigationController?.tabBarController?.tabBar.hidden = true
    navigationController?.setNavigationBarHidden(true, animated: true)
    newNameView.newNameTextField.text?.removeAll()
    newNameView.hidden = false
    blurView.hidden = false
    newNameView.alpha = 1
    newNameView.transform = CGAffineTransformTranslate(newNameView.transform, 0, self.view.frame.height/2)
    UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: [], animations: {
      self.newNameView.transform = CGAffineTransformIdentity
      self.blurView.alpha = 1
      }, completion: { (_) in
        
    })
  }
  
  @objc private func keyboardWillAppear(notification: NSNotification) {
    // 获取键盘信息
    let keyboardinfo = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]
    let keyboardheight:CGFloat = (keyboardinfo?.CGRectValue.size.height)!
    textView.contentInset.bottom = keyboardheight
    
    textView.scrollIndicatorInsets.bottom = textView.contentInset.bottom
  }
  
  /// 新建脚本
  private func addScript() {
    self.view.showHUD()
    let parameters = [
      "filename": newNameView.newNameTextField.text!+self.extensionName,
      "data": self.data
    ]
    let request = Network.sharedManager.post(url: ServiceURL.Url.newScriptFile, timeout: Constants.Timeout.request, parameters: parameters)
    let session = Network.sharedManager.session()
    let task = session.dataTaskWithRequest(request) { [weak self] data, _, error in
      guard let `self` = self else { return }
      self.view.hideHUD()
      if let data = data {
        let json = JSON(data: data)
        switch json["code"].intValue {
        case 0:
          self.view.showHUD(.Message, text: Constants.Text.createDone, autoHide: true, autoHideDelay: 0.5, completionHandler: {
            self.closeNewNameViewAnimator()
            self.onef_navigationBack(false)
            self.delegate?.reloadScriptList()
          })
        default:
          self.alert(title: Constants.Text.prompt, message: json["message"].stringValue, delegate: nil, cancelButtonTitle: Constants.Text.ok)
        }
      }
      if error != nil {
        self.alert(title: Constants.Text.prompt, message: Constants.Error.failure, delegate: nil, cancelButtonTitle: Constants.Text.ok)
      }
    }
    task.resume()
  }
}

extension NewScriptViewController: UITextViewDelegate {
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    if self.textView.text.characters.count == 0 {
      self.placeHolderLabel.hidden = true
      self.textView.text = Constants.Text.startScript
      return true
    }
    return true
  }
}
