//
//  LoginViewController.swift
//  Project-Group6
//
//  Created by Cena Nguyen on 2026-07-02.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {
    var iconClick = false
    let imageicon = UIImageView()

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text,
              let pass = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
            if let u = user{
                self.performSegue(withIdentifier: "goToGame", sender: self)
            }
            else{}})
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
    }
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let tappedImage = sender.view as! UIImageView
        
        passwordTextField.isSecureTextEntry.toggle()
        
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
