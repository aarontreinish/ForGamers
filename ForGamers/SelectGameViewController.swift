//
//  SelectGameViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 5/16/21.
//

import UIKit

class SelectGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var results: [Results] = []
    
    private var numberOfItemsInRow = 2

    private var minimumSpacing = 5

    private var edgeInsetPadding = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getGames()
    }
    
    func getGames() {
        guard let gitUrl = URL(string: "https://api.rawg.io/api/games?key=10bcc8f8934643b9b9e6b44b7e814086&ordering=popular") else { return }
        
        URLSession.shared.dataTask(with: gitUrl) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(RAWG.self, from: data)
                
                self.results = data.results ?? []
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch let err {
                print("Error", err)
            }
        }.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectGameCell", for: indexPath) as? SelectGameCollectionViewCell else { return UICollectionViewCell() }
        
        let result = results[indexPath.row]
        
        cell.nameLabel.text = result.name ?? ""
        cell.gameImageView.loadImageUsingCacheWithUrlString(urlString: result.background_image ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let result = self.results[indexPath.row]
        let selectedImage = result.background_image
        
        if let tabBar = self.presentingViewController as? UITabBarController {
            let homeNavigationViewController = tabBar.viewControllers![2] as? UINavigationController
            let createViewController = homeNavigationViewController?.topViewController as! CreateViewController
            createViewController.communityImageView.loadImageUsingCacheWithUrlString(urlString: selectedImage ?? "")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        edgeInsetPadding = Int(inset.left + inset.right)
        return inset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (Int(UIScreen.main.bounds.size.width) - (numberOfItemsInRow - 1) * minimumSpacing - edgeInsetPadding) / numberOfItemsInRow
            return CGSize(width: width, height: width)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(minimumSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(minimumSpacing)
    }
    
}
