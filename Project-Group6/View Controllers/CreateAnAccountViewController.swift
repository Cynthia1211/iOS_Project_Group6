//
//  CreateAnAccountViewController.swift
//  Project-Group6
//
//  Created by Cena Nguyen on 2026-07-02.
//

import UIKit
import FirebaseAuth
class CreateAnAccountViewController: UIViewController {
    var iconClick = false
    let imageicon = UIImageView()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var verifyTextField: UITextField!
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let pass = passwordTextField.text,
        let verifyPassword = verifyTextField.text else {
            return}
            
            // 1. Check for blank fields
            if email.isEmpty || pass.isEmpty || verifyPassword.isEmpty {
                showAlert(title: "Error",
                          message: "Please fill in all fields.")
                return
            }
            
            // 2. Validate password strength
            if !isValidPassword(pass) {
                showAlert(title: "Invalid Password",
                          message: "Password must be at least 10 characters long and include:\n• One uppercase letter\n• One lowercase letter\n• One number\n• One special character")
                return
            }
            
            // 3. Verify passwords match
            if pass != verifyPassword {
                showAlert(title: "Password Mismatch",
                          message: "Verify Password must match Password.")
                return
            }
        Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in

                    if let error = error {
                        self.showAlert(title: "Registration Failed",
                                       message: error.localizedDescription)
                        return
                    }

                    self.performSegue(withIdentifier: "goToLogin", sender: self)
                }
            }
    func isValidPassword(_ password: String) -> Bool {

            let passwordRegex =
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&#^()_+=\\-]).{10,}$"

            let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

            return passwordTest.evaluate(with: password)
        }

        // Alert Function
        func showAlert(title: String, message: String) {

            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK",
                                          style: .default))

            present(alert, animated: true)
        }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = UIImage(named: "closeeye") else { return }
        
        imageicon.image = image
        
        imageicon.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        
        let contentView = UIView(frame: imageicon.frame)
        contentView.addSubview(imageicon)
        
        passwordTextField.rightView = contentView
        passwordTextField.rightViewMode = .always
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        
        imageicon.isUserInteractionEnabled = true
        imageicon.addGestureRecognizer(tapGestureRecognizer)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let tappedImage = sender.view as! UIImageView
        
        passwordTextField.isSecureTextEntry.toggle()
        
        if passwordTextField.isSecureTextEntry {
            tappedImage.image = UIImage(named: "closeeye")
        } else {
            tappedImage.image = UIImage(named: "openeye")
        }
        
    }

}
