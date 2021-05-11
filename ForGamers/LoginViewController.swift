//
//  LoginViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/7/21.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        let email = "example@gmail.com"
//        let password = "fooPassword"
//        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
//            if let error = error as NSError? {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .operationNotAllowed:
//                // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
//                case .userDisabled:
//                // Error: The user account has been disabled by an administrator.
//                case .wrongPassword:
//                // Error: The password is invalid or the user does not have a password.
//                case .invalidEmail:
//                // Error: Indicates the email address is malformed.
//                default:
//                    print("Error: \(error.localizedDescription)")
//                }
//            } else {
//                print("User signs in successfully")
//                let userInfo = Auth.auth().currentUser
//                let email = userInfo?.email
//            }
//        }
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func signIn(email: String, password: String, completion: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                    self?.showErrorAlert(title: "Account not enabled", message: "The email and password you entered are not enabled")
                    completion(false, error)
                    print(error)
                case .userDisabled:
                    // Error: The user account has been disabled by an administrator.
                    self?.showErrorAlert(title: "User disabled", message: "The user account has been disabled by an administrator.")
                    completion(false, error)
                    print(error)
                case .wrongPassword:
                    // Error: The password is invalid or the user does not have a password.
                    self?.showErrorAlert(title: "Incorrect password", message: "The password you have entered is incorrect or invalid.")
                    completion(false, error)
                    print(error)
                case .invalidEmail:
                    // Error: Indicates the email address is malformed.
                    self?.showErrorAlert(title: "Incorrect email", message: "The email you have entered is incorrect or invalid.")
                    completion(false, error)
                    print(error)
                default:
                    self?.showErrorAlert(title: "Error logging in", message: "There was an error logging in. Please try again later.")
                    completion(false, error)
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                print("User signs in successfully")
                UserDefaults.standard.set(email, forKey: "email")
                completion(true, nil)
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        if isValidEmail(email) {
            signIn(email: email, password: password) { (didSucceed, error) in
                if didSucceed == true {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
                        
                    // This is to get the SceneDelegate object from your view controller
                    // then call the change root view controller function to change to main tab bar
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabBarController)
                } else {
                    if let error = error {
                        print(error)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
}
