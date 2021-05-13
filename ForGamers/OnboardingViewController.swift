//
//  OnboardingViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 5/13/21.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController, PaperOnboardingDataSource {
    
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UserDefaults.standard.setValue(true, forKey: "hasSeenOnboarding")
        
        let onboarding = PaperOnboarding()
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
        
        view.bringSubviewToFront(skipButton)
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {

       return [
        OnboardingItemInfo(informationImage: UIImage(systemName: "person.3.fill")!,
                                       title: "Join your favorite gaming community",
                                 description: "",
                                 pageIcon: UIImage(systemName: "person.3.fill")!,
                                 color: .systemBackground,
                                 titleColor: .label,
                                 descriptionColor: .label,
                                  titleFont: .systemFont(ofSize: 20),
                             descriptionFont: .systemFont(ofSize: 15)),

        OnboardingItemInfo(informationImage: UIImage(systemName: "person.3.fill")!,
                                       title: "Make posts in your favorite community",
                                 description: "",
                                 pageIcon: UIImage(systemName: "person.3.fill")!,
                                 color: .systemBackground,
                                 titleColor: .label,
                                 descriptionColor: .label,
                                  titleFont: .systemFont(ofSize: 20),
                             descriptionFont: .systemFont(ofSize: 15)),

        OnboardingItemInfo(informationImage: UIImage(systemName: "person.3.fill")!,
                                       title: "Message other users",
                                 description: "",
                                 pageIcon: UIImage(systemName: "person.3.fill")!,
                                 color: .systemBackground,
                                 titleColor: .label,
                                 descriptionColor: .label,
                                  titleFont: .systemFont(ofSize: 20),
                             descriptionFont: .systemFont(ofSize: 15))
         ][index]
     }

     func onboardingItemsCount() -> Int {
        return 3
      }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
            
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabBarController)
    }
    
}
