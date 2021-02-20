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
    
    
    //MARK: Properties
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth:  -1.0
    ]
    var completionHandler : (_ isUpdated: Bool) -> Void = {(_) in}
    var isEdit:Bool = false
    var oldMeme: MemeMe!
    var defaultTopText: String{
        return isEdit ? oldMeme.topText : "TOP"
    }
    var defaultBottomText: String{
        return isEdit ? oldMeme.bottomText : "BOTTOM"
    }
    
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTextField(textField: topTextField, withText: defaultTopText)
        initializeTextField(textField: bottomTextField, withText: defaultBottomText)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareMeme))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelMemeMeEditor))
        navigationItem.leftBarButtonItem?.isEnabled = isEdit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isEdit == true{
            imageView.image = oldMeme.originalImage
            isEdit = false
            
        }
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotifications()
    }

    //MARK: initializeViews
    private func initializeTextField(textField: UITextField, withText defaultText: String){
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    //MARK: Actions
    @IBAction func selectImageFromAlbum(_ sender: Any) {
        presentImagePickerWith(.photoLibrary)
        
    }
    @IBAction func selectImageFromCamera(_ sender: Any) {
        presentImagePickerWith(.camera)
    }
    
    private func presentImagePickerWith(_ sourceType: UIImagePickerController.SourceType){
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        
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
            view.frame.origin.y = -getKeyboardHieght(notification)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification){
        if bottomTextField.isEditing {
            view.frame.origin.y = 0
        }
    }
    
    private func getKeyboardHieght(_ notification: Notification) -> CGFloat {
        
        let info = notification.userInfo
        let keyboardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
    
    //MARK: Utility Funnctions
    @objc private func cancelMemeMeEditor(){
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private func save(_ memedImage: UIImage) {
        
        let meme = MemeMe(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memeMeImage: memedImage)
        
        //add to shared model
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        
    }
    
    @objc private func shareMeme(){
        
        let memedImage  = generateMemedImage()
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            if !completed {
                self.completionHandler(false)
                return
            }
            
            self.save(memedImage)
            self.completionHandler(true)
            self.dismiss(animated: true, completion: nil)
            
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

