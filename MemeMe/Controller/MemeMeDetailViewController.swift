//
//  MemeMeDetailViewController.swift
//  MemeMe
//
//  Created by Ismail on 26/01/2021.
//

import UIKit

class MemeMeDetailViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var memeMeImageView: UIImageView!
    
    //MARK: Default properties
    var meme: MemeMe!
    var memeIndex: Int!
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()

        memeMeImageView.image = meme.memeMeImage
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(tabToEdit))
    }
    
    //MARK: Utility Funnctions
    @objc private func tabToEdit(){
        
        let memeMeViewController = storyboard?.instantiateViewController(identifier: Util.editorIdentifier) as! MemeMeViewController
        
        memeMeViewController.isEdit =  true
        memeMeViewController.oldMeme = meme
        memeMeViewController.completionHandler = {(isUpdated) in
            if isUpdated {
                
                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                
                //update old meme with edited meme
                self.meme = appDelegate.memes[appDelegate.memes.count - 1]
                
                //remove old meme from array
                appDelegate.memes.remove(at: self.memeIndex)
                
                //update index
                self.memeIndex = appDelegate.memes.count - 1
                
                self.updateView()
                
            }
        }
        let navigation = UINavigationController(rootViewController: memeMeViewController)
        
        present(navigation, animated: true, completion: nil)
    }
    
    private func updateView(){
        if let meme = self.meme {
            memeMeImageView.image = meme.memeMeImage
        }
    }
    
}
