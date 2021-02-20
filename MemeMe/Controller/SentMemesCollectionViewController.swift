//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Ismail on 21/01/2021.
//

import UIKit

class SentMemesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //MARK: Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    //MARK: Properties
    var memes: [MemeMe]! {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Util.sentMemesTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tapToCreate))
        
        configureLayoutSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    //MARK: Delegates Funtions
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(identifier: Util.detailIdentifier) as! MemeMeDetailViewController
        
        viewController.meme = memes[indexPath.row]
        viewController.memeIndex = indexPath.row
        
        navigationController?.pushViewController(viewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        memes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier:  Util.collectionCellIdentifier, for: indexPath) as! MemeCollectionViewCell
        
        let meme = memes[indexPath.row]
        
        cell.collectionImageView.image = meme.memeMeImage
        
        return cell

    }
    
    //MARK: Utility Funnction
    @objc private func tapToCreate(){
        
        let memeMeViewController = storyboard?.instantiateViewController(identifier: Util.editorIdentifier) as! MemeMeViewController
        memeMeViewController.completionHandler = {(isUpdated) in
            if isUpdated {
                self.collectionView.reloadData()
            }
        }
        let navigation = UINavigationController(rootViewController: memeMeViewController)
        
        present(navigation, animated: true, completion: nil)
    }
    
    private func configureLayoutSize(){
        let space: CGFloat = 3.0
        let edgeLength = (self.view.frame.size.width < self.view.frame.size.height) ?
            self.view.frame.size.width : self.view.frame.size.height
        let dimension = (edgeLength - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
