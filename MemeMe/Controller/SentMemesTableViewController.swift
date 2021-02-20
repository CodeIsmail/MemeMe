//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Ismail on 21/01/2021.
//

import UIKit

class SentMemesTableViewController: UIViewController, UITableViewDataSource {

    //MARK: Outlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Property
    var memes: [MemeMe]!{
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Util.sentMemesTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tapToCreate))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: Delegate functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(identifier: Util.detailIdentifier) as! MemeMeDetailViewController
        viewController.meme = memes[indexPath.row]
        viewController.memeIndex = indexPath.row
        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: Util.tableCellIdentifier, for: indexPath) as! MemeTableViewCell
        let meme = memes[indexPath.row]
        
        cell.memeImage.image = meme.memeMeImage
        cell.summary.text = "\(meme.topText)...\(meme.bottomText)"
        
        return cell
    }
    
    //MARK: Utility Funtion
    @objc private func tapToCreate(){
        
        let memeMeViewController = storyboard?.instantiateViewController(identifier: Util.editorIdentifier) as! MemeMeViewController
        memeMeViewController.completionHandler = {(isUpdated) in
            if isUpdated {
                self.tableView.reloadData()
            }
        }
        let navigation = UINavigationController(rootViewController: memeMeViewController)
        
        present(navigation, animated: true, completion: nil)
    }
}
