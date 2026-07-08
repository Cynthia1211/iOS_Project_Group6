//
//  CreateAnAccountViewController.swift
//  Project-Group6
//
//  Created by Cena Nguyen on 2026-07-02.
//

import UIKit
import FirebaseAuth
/**
 Principal Author: Cena Nguyen
 
 Description:
 This view controller manages the account creation screen.
 It validates user input, verifies password requirements,
 creates a new Firebase Authentication account, and navigates
 the user to the login screen after successful registration.
 */
class CreateAnAccountViewController: UIViewController {
    // Stores the current state of the password visibility icon.
    // This can be used to determine whether the password is hidden or visible.
    var iconClick = false
    // Image view used as an eye icon to allow users to show or hide their password.
    let imageicon = UIImageView()
    // Stores the email entered by the user during account registration.
    @IBOutlet weak var emailTextField: UITextField!
    
    // Stores the password entered by the user during account registration.
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Stores the password confirmation entered by the user to ensure both passwords match.
    @IBOutlet weak var verifyTextField: UITextField!
    
    /**
        Handles the account creation button action.
        
        This method validates the user's registration information before creating
        a Firebase account. Validation is performed first to prevent invalid data
        from being sent to Firebase.
        
        - Parameter sender: The button that triggered this action.
        */
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let pass = passwordTextField.text,
        let verifyPassword = verifyTextField.text else {
            return}
            
            // Prevents account creation when required fields are empty.
            // This improves user experience by informing users immediately about missing data.
            if email.isEmpty || pass.isEmpty || verifyPassword.isEmpty {
                showAlert(title: "Error",
                          message: "Please fill in all fields.")
                return
            }
            
            // Ensures users create stronger passwords before storing credentials.
            // Strong password requirements help reduce unauthorized account access.
            if !isValidPassword(pass) {
                showAlert(title: "Invalid Password",
                          message: "Password must be at least 10 characters long and include:\n• One uppercase letter\n• One lowercase letter\n• One number\n• One special character")
                return
            }
            
            // Prevents account creation when the password confirmation does not match.
            // This avoids users accidentally registering with an unknown password.
            if pass != verifyPassword {
                showAlert(title: "Password Mismatch",
                          message: "Verify Password must match Password.")
                return
            }
        // Firebase is used to securely manage user authentication instead of storing passwords locally.
        Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in

                    if let error = error {
                        self.showAlert(title: "Registration Failed",
                                       message: error.localizedDescription)
                        return
                    }
            // Moves the user to the login page after successful account creation.
             // This allows the user to authenticate using the newly created account.
                    self.performSegue(withIdentifier: "goToLogin", sender: self)
                }
            }
    /**
         Validates whether the password meets the application's security requirements.
         
         Passwords must contain uppercase letters, lowercase letters,
         numbers, special characters, and have a minimum length.
         
         - Parameter password: The password entered by the user.
         - Returns: True if the password meets requirements, otherwise false.
         */
    func isValidPassword(_ password: String) -> Bool {
           // A regular expression is used to enforce password rules consistently.
            // This prevents weak passwords from being accepted during registration.
            let passwordRegex =
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&#^()_+=\\-]).{10,}$"

            let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

            return passwordTest.evaluate(with: password)
        }

    /**
        Displays an alert message to provide feedback to the user.
        
        This centralized method avoids repeating alert creation code
        throughout the view controller.
        
        - Parameters:
           - title: The title displayed in the alert.
           - message: The explanation shown to the user.
        */
        func showAlert(title: String, message: String) {

            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default))

            present(alert, animated: true)
        }
    /**
        Dismisses the keyboard when the user taps outside a text field.
        
        This improves usability by allowing users to view the entire screen
        after entering information.
        */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
        
    
    /**
        Performs initial setup when the account creation screen loads.
        
        The password visibility icon is configured here so users can easily
        switch between hidden and visible password input.
        */
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = UIImage(named: "closeeye") else { return }
        
        imageicon.image = image
        
        imageicon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        // The container view allows the image icon to appear inside the text field.
        let contentView = UIView(frame: imageicon.frame)
        contentView.addSubview(imageicon)
        
        passwordTextField.rightView = contentView
        passwordTextField.rightViewMode = .always
        // Allows users to tap the eye icon to change password visibility.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        
        imageicon.isUserInteractionEnabled = true
        imageicon.addGestureRecognizer(tapGestureRecognizer)

        
    }
    

    /**
         Handles the password visibility toggle action.
         
         This method allows users to temporarily view their password,
         helping prevent typing mistakes during account creation.
         
         - Parameter sender: The gesture recognizer that detected the tap.
         */
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let tappedImage = sender.view as! UIImageView
        // Toggle visibility so users can verify the password they entered.
        passwordTextField.isSecureTextEntry.toggle()
        // Updates the icon to match the current password visibility state.
        if passwordTextField.isSecureTextEntry {
            tappedImage.image = UIImage(named: "closeeye")
        } else {
            tappedImage.image = UIImage(named: "openeye")
        }
        
    }

}
