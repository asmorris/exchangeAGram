//
//  ProfileViewController.swift
//  exchangeAGram
//
//  Created by Andrew Morrison on 2016-03-22.
//  Copyright © 2016 Andrew Morrison. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = CGPointMake(150, 400)
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "fbProfileChanged:",
            name: FBSDKProfileDidChangeNotification,
            object: nil)
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        // If we have a current Facebook access token, force the profile change handler
        if ((FBSDKAccessToken.currentAccessToken()) != nil)
        {
            self.fbProfileChanged(self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - IBActions
    
    @IBAction func mapViewButtonPressed(sender: UIButton) {
        
        performSegueWithIdentifier("mapSegue", sender: nil)
        
    }
    
    
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error != nil)
        {
            print( "\(error.localizedDescription)" )
        }
        else if (result.isCancelled)
        {
            // Logged out?
            print( "Login Cancelled")
        }
        else
        {
            // Logged in?
            print( "Logged in")
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        profileImageView.hidden = true
        nameLabel.hidden = true
    }
    
    //MARK: - Helper Functions
    
    
    func fbProfileChanged(sender: AnyObject!) {
        
        let fbProfile = FBSDKProfile.currentProfile()
        if (fbProfile != nil)
        {
            // Fetch & format the profile picture
            let strProfilePicURL = fbProfile.imagePathForPictureMode(FBSDKProfilePictureMode.Square, size: self.profileImageView.frame.size)
            let url = NSURL(string: strProfilePicURL, relativeToURL: NSURL(string: "https://graph.facebook.com/"))
            let imageData = NSData(contentsOfURL: url!)
            let image = UIImage(data: imageData!)
            
            self.nameLabel.text = fbProfile.name
            self.profileImageView.image = image
            
            self.nameLabel.hidden = false
            self.profileImageView.hidden = false
        }
        else
        {
            self.nameLabel.text = ""
            self.profileImageView.image = UIImage(named: "")
            
            self.nameLabel.hidden = true
            self.profileImageView.hidden = true
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
