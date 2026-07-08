//
//  LoginViewController.swift
//  Project-Group6
//
//  Created by Cena Nguyen on 2026-07-02.
//

import UIKit
import FirebaseAuth
/**
 Principal Author: Cena Nguyen
 
 Description:
 This view controller manages the user login screen.
 It collects user credentials, authenticates users through Firebase Authentication,
 and navigates successful users to the game screen.
 */
class LoginViewController: UIViewController {
    // Stores the current state of the password visibility icon.
    // This can be used to track whether the password is currently hidden or visible.
    var iconClick = false
    // Image view used as an eye icon to allow users to show or hide their password.
    let imageicon = UIImageView()
    // Stores the email entered by the user for authentication.
    @IBOutlet weak var emailTextField: UITextField!
    // Stores the password entered by the user for authentication.
    @IBOutlet weak var passwordTextField: UITextField!
    /**
         Handles the login button action.
         
         This method retrieves the user's credentials and sends them to Firebase
         Authentication. Firebase is used to securely verify the user's identity
         instead of manually storing and checking passwords.
         
         - Parameter sender: The button that triggered this action.
         */
    @IBAction func submitPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text,
              let pass = passwordTextField.text else {
            return
        }
        // Firebase authentication is used here to prevent storing user passwords
        // locally and to allow secure login verification.
        Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
            if let u = user{
                // The user is redirected only after successful authentication
                // to prevent unauthorized access to the game screen.
                self.performSegue(withIdentifier: "goToGame", sender: self)
            }
            else{
                // Login failure is ignored currently.
                // Error handling can be added here to inform users about invalid
            }})
    }
    /**
         Dismisses the keyboard when the user taps outside a text field.
         
         This improves usability by allowing users to view the entire login screen
         without the keyboard blocking interface elements.
         */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    /**
         Performs initial setup when the login screen loads.
         
         The password visibility icon is configured here so users can choose
         whether to view or hide their password while typing.
         */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The eye icon is added to improve usability by allowing users
        // to verify their password input before logging in.
        guard let image = UIImage(named: "closeeye") else { return }
        
        imageicon.image = image
        
        imageicon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        // A container view is required so the icon can be displayed
        // correctly inside the password text field.
        let contentView = UIView(frame: imageicon.frame)
        contentView.addSubview(imageicon)
        
        passwordTextField.rightView = contentView
        passwordTextField.rightViewMode = .always
        // A tap gesture allows users to interact with the icon
        // without requiring an additional button on the screen.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        
        imageicon.isUserInteractionEnabled = true
        imageicon.addGestureRecognizer(tapGestureRecognizer)
    }
    /**
        Handles the password visibility toggle action.
        
        This method allows users to temporarily view their password,
        helping them confirm that the entered password is correct.
        
        - Parameter sender: The gesture recognizer that detected the tap.
        */
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let tappedImage = sender.view as! UIImageView
        // Changing the secure text setting improves user experience
        // by allowing users to check their password when needed.
        passwordTextField.isSecureTextEntry.toggle()
        // The icon changes depending on whether the password is hidden
        // or visible, providing visual feedback to the user.
        if passwordTextField.isSecureTextEntry {
            tappedImage.image = UIImage(named: "closeeye")
        } else {
            tappedImage.image = UIImage(named: "openeye")
        }
        
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
