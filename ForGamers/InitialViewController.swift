//
//  InitialViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 5/13/21.
//

import UIKit
import AuthenticationServices

class InitialViewController: UIViewController {

    @IBOutlet weak var signInWithApple: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setUpSignInButton() {
        let button = ASAuthorizationAppleIDButton()
        button.center = view.center
        view.addSubview(button)
    }
    
    @IBAction func signInWithAppleButtonAction(_ sender: Any) {

    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
