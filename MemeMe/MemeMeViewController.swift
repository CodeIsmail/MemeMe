//
//  ViewController.swift
//  MemeMe
//
//  Created by Ismail on 05/01/2021.
//

import UIKit

class MemeMeViewController: UIViewController, UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    //MARK: Default properties
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -1.0
    ]
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unSubscribeToKeyboardNotifications()
    }

    //MARK: initializeViews
    private func initializeViews(){
        topTextField.text = defaultTopText
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        topTextField.delegate = self
        
        bottomTextField.text = defaultBottomText
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        bottomTextField.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareMeme))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(resetMemeMe))
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    //MARK: Actions
    @IBAction func selectImageFromAlbum(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    @IBAction func selectImageFromCamera(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Keyboard Notification
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    private func unSubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func keyboardWillShow(_ notification: Notification){
        
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHieght(notification)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification){
        if bottomTextField.isEditing {
            view.frame.origin.y += getKeyboardHieght(notification)
        }
    }
    
    private func getKeyboardHieght(_ notification: Notification) -> CGFloat {
        
        let info = notification.userInfo
        let keyboardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    //MARK: Utility Funnctions
    @objc private func resetMemeMe(){
        topTextField.text = defaultTopText
        bottomTextField.text = defaultBottomText
        imageView.image = nil
        navigationItem.leftBarButtonItem?.isEnabled = false
        
    }
    
    private func save(_ memedImage: UIImage) {
        
        let meme = MemeMe(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memeMeImage: memedImage)
        
    }
    
    @objc private func shareMeme(){
        
        let memedImage  = generateMemedImage()
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            if !completed {
                return
            }
            
            self.save(memedImage)
            
        }
        present(activityController, animated: true, completion: nil)
    }
    private func generateMemedImage() -> UIImage {

        hideTopLevelViews(true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        hideTopLevelViews(false)
        
        return memedImage
    }
    
    private func hideTopLevelViews(_ isVisible: Bool){
        toolbar.isHidden = isVisible
        navigationController?.navigationBar.isHidden = isVisible
    }
    
    //MARK: Delegate functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
                    imageView.image = image
            navigationItem.leftBarButtonItem?.isEnabled = true
                }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

