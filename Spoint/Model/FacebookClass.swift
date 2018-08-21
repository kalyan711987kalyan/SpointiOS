//
//  FacebookClass.swift
//  SocialLogin
//
//  Created by Ketan on 12/26/16.
//  Copyright © 2016 kETANpATEL. All rights reserved.
//

import UIKit


typealias FBSuccessHandler = (_ success:AnyObject) -> Void
typealias FBFailHandler = (_ success:AnyObject) -> Void


class FacebookClass: NSObject {
    
   /* var vc: UIViewController!
    var loginFail: FBFailHandler?
    var loginSucess: FBSuccessHandler?
    
    static var facebookClass: FacebookClass!
    
    class func sharedInstance() -> FacebookClass {
        
        if(facebookClass == nil) {
            facebookClass = FacebookClass()
        }
        return facebookClass
    }
    
    //MARK: - Logout Facebook
    
    func logoutFromFacebook() {
        

        let loginManager = LoginManager()
            loginManager.logOut()

    }
    
    //MARK: - Login with Facebook
    
    func loginWithFacebook(viewController: UIViewController, successHandler: @escaping FBSuccessHandler, failHandler: @escaping FBFailHandler) {

        vc = viewController
        loginFail = failHandler
        loginSucess = successHandler
        


            if(AccessToken.current == nil) {
                
                let loginManager = LoginManager()


                loginManager.logIn(readPermissions:[.publicProfile, .userFriends, .email], viewController: viewController) { loginResult in
                    
                    switch loginResult {
                    case .failed(let error):
                        print(error)
                        self.loginFail!(error.localizedDescription as AnyObject)
                    case .cancelled:
                        print("User cancelled login.")
                        self.loginFail!("User cancelled login." as AnyObject)
                    case .success( _, _, let tokenstr):
                        print("Logged in! \(tokenstr)")
                        AccessToken.current = tokenstr
                        self.getUserInfoFromFB()
                    }
                }
            }
            else {
                //AccessToken.current = strToken
                self.getUserInfoFromFB()
            }

    }
    
    func getUserInfoFromFB() {
        
        let params = ["fields":"cover,picture.type(large),id,name,first_name,last_name,gender,birthday,email,location,hometown"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                self.loginFail!(error.localizedDescription as AnyObject)
                break
            case .success(let graphResponse):
                
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    self.loginSucess!(responseDictionary as AnyObject)
                }
            }
        }
        
    }
    
    //MARK: - Get List Of Facebook Friends
    
    func getFacebookFriends(viewController: UIViewController, successHandler: @escaping FBSuccessHandler, failHandler: @escaping FBFailHandler) {
        
        vc = viewController
        loginFail = failHandler
        loginSucess = successHandler


            if(AccessToken.current == nil) {
                
                let loginManager = LoginManager()
                
                loginManager.logIn(readPermissions:[.publicProfile, .userFriends, .email], viewController: viewController) { loginResult in
                    
                    switch loginResult {
                    case .failed(let error):
                        print(error)
                        self.loginFail!(error.localizedDescription as AnyObject)
                    case .cancelled:
                        print("User cancelled login.")
                        self.loginFail!("User cancelled login." as AnyObject)
                    case .success( _, _, let tokenstr):
                        print("Logged in! \(tokenstr)")
                        AccessToken.current = tokenstr
                        self.getUserFacebookFriendsFromFB()
                    }
                }
                
            }
            else {
                self.getUserFacebookFriendsFromFB()
            }

    }
    
    
    func getUserFacebookFriendsFromFB() {
        
        let params = ["fields":"cover,picture.type(large),id,name,first_name,last_name,gender,birthday,email,location,hometown"]
        let graphRequest = GraphRequest(graphPath: "me/friends", parameters: params)
        
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult {
                
            case .failed(let error):
                print("error in graph request:", error)
                self.loginFail!(error.localizedDescription as AnyObject)
                break
                
            case .success(let graphResponse):
                
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    self.loginSucess!(responseDictionary as AnyObject)
                }
            }
        }
    }*/
}
