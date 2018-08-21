//
//  ViewController.swift
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import FirebaseAuth
import SafariServices

enum OtpState: Int{

    case notRecieved
    case recieved

}
extension NSLocale
{
    class func localeForCountry(countryName : String) -> String?
    {
        return NSLocale.isoCountryCodes.first{self.countryNameFromLocaleCode(localeCode: $0 ) == countryName}
    }
    
    private class func countryNameFromLocaleCode(localeCode : String) -> String
    {
        return NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.countryCode, value: localeCode) ?? ""
    }
}
class ViewController: UIViewController,UITextFieldDelegate,CountryPhoneCodePickerDelegate, SFSafariViewControllerDelegate, UIScrollViewDelegate {

    @IBOutlet var otpTextField: UITextField!
    @IBOutlet var otpimageView : UIImageView!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var otpView: UIView!
    @IBOutlet var countryView: UIView!
    @IBOutlet var countryCodeLbl: UILabel!
    @IBOutlet var countryImage : UIImageView!
    @IBOutlet var countryNameLbl : UILabel!
    @IBOutlet var secsLabel: UILabel!
    @IBOutlet var resendButton : UIButton!
    var state: OtpState = OtpState.notRecieved
    @IBOutlet weak var phoneTextField: STextField!
    @IBOutlet var scrollview: TPKeyboardAvoidingScrollView!
    var timer: Timer!
    var seconds = 60
    var verificationID : String?
    var verificationCode: String?
    @IBOutlet var placeHolderImageView: UIImageView!
    var countryPhoneCodePicker = CountryPicker()
    @IBOutlet var customPickerView: UIView!
    var serverSwitchValue = 0

    @IBOutlet var closeButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.

//        placeHolderImageView.animationDuration = 1
//        placeHolderImageView.startAnimating()
       otpView.isHidden = true
        countryView.isHidden = false

        countryPhoneCodePicker.countryPhoneCodeDelegate = self
        _ = Locale.current.regionCode!
        
        if  let id = Auth.auth().currentUser?.uid {
            
            FireBaseContants.firebaseConstant.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if ((snapshot.value as? [String:Any]) != nil){
                    if ((snapshot.childSnapshot(forPath: keys.usernameKey).value as? String) != nil) {
                        DispatchQueue.main.async {
                            //self.performSegue(withIdentifier: "login2Dashboard", sender: self)
                            self.moveToDashboard()
                        }
                    }else{
                        self.placeHolderImageView.isHidden = true
                    }
                }else{
                    self.placeHolderImageView.isHidden = true
                }
            })
        }else{
            placeHolderImageView.isHidden = true
        }
        
        termsButton.isSelected = true

        //FireBaseContants.firebaseConstant.serverurl = "Spoint-Database"


    }
    
    func moveToDashboard() {
        if ((Auth.auth().currentUser?.uid) != nil) && UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) != nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "login2Dashboard", sender: self)
            }
        }else{
            placeHolderImageView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func termsBtnAction(sender: UIButton){

        if  sender.isSelected {
            //sender.isSelected = false
            //resendButton.isHidden = true

        }else {
            //sender.isSelected = true
            //resendButton.isHidden = false
        }
    }

    @IBAction func readTermsAndConditions(){

        termsButton.isSelected = true
        resendButton.isHidden = false
        let safariVC = SFSafariViewController(url: NSURL(string: "https://docs.google.com/document/d/1LDB-GSDw0M2O8YuUU1_3ouAU8DxSkjOVb4KeKrWMpPM/edit?usp=sharing")! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    @IBAction func getOTPButtonAction(sender:UIButton){

        if !ReachabilityManager.shared.isNetworkAvailable {
            self.showAlertWithTitle(title: "Sorry!", message: "No Internet", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })
            return
        }

        if (self.phoneTextField.text?.characters.count)! < 9 {
            self.showAlertWithTitle(title: "Sorry!", message: "Please enter valid phone number!", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })
            return
        }
        if state.rawValue == 0 {

            self.generateOTP()

        }else if seconds == 60{
            self.showAlertWithTitle(title: "Sorry!", message: "OTP is invalid. Please resend.", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })
        }else{

            if termsButton.isSelected{
                self.showLoaderWithMessage(message: "Loading")

                let credential = PhoneAuthProvider.provider().credential(
                    withVerificationID: verificationID ?? "",
                    verificationCode: self.otpTextField.text ?? "")
                Auth.auth().signIn(with: credential) { (user, error) in

                    self.dismissLoader()
                    if let error = error {
                        self.showAlertWithTitle(title: "Sorry!", message: error.localizedDescription, buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

                        })
                        return
                    }else{
                        self.timer.invalidate()
                        UserDefaults.standard.set(self.phoneTextField.text, forKey: UserDefaultsKey.phoneNoKey)

                        self.performSegue(withIdentifier: "RegisterSegue", sender: self)
                        self.phoneTextField.text = ""
                        self.otpTextField.text = ""

                    }

                }


            }else{
                self.showAlertWithTitle(title: "Sorry!", message: "Please accept Terms & Conditions", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

                })
            }
        }
    }
    @IBAction func resendButtonAction(){

        if !self.istermsSelected(){
            self.showAlertWithTitle(title: "Sorry!", message: "Please accept Terms & Conditions", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })
return
        }
        resendButton.isHidden = false
        self.generateOTP()
    }



    @objc func updateTimer() {
        if seconds == 0 {
            timer.invalidate()
            resendButton.isHidden = false
            seconds = 60
        }else{
            seconds -= 1
            secsLabel.text = "\(seconds) Secs"
        }

    }
    func updateUIWithState(state:OtpState){

        switch state {
        case .notRecieved:
             registerButton.setTitle("", for: .normal)
            break
        case .recieved:
            registerButton.setTitle("Login", for: .normal)

             break
        default:
            break
        }
    }
    func generateOTP(){

        if !ReachabilityManager.shared.isNetworkAvailable {
            self.showAlertWithTitle(title: "Sorry!", message: "No Internet", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })
            return
        }

        if !self.istermsSelected(){
            self.showAlertWithTitle(title: "Sorry!", message: "Please accept Terms & Conditions", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })

            return
        }
        otpView.isHidden = false
        countryView.isHidden = true
        state = OtpState.recieved
        resendButton.isHidden = false
        self.updateUIWithState(state: state)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)

        PhoneAuthProvider.provider().verifyPhoneNumber(countryCodeLbl.text!+phoneTextField.text!, uiDelegate:nil ) { (verificationId, error) in
            if let error = error {
                self.showAlertWithTitle(title: "ERROR", message: error.localizedDescription, buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

                })
                return
            }
            guard let verificationId = verificationId else { return }

            self.verificationID = verificationId
        }
        // [END phone_auth]

    }
    @IBAction func showPicker() {
        let iOSDeviceScreenSize = UIScreen.main.bounds.size

        customPickerView.isHidden = false
        //Adding toolbar
        let toolBar = UIToolbar(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(iOSDeviceScreenSize.width), height: CGFloat(44)))
        toolBar.sizeToFit()
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.RedColor()

        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissPicker))
        btnDone.tintColor = UIColor.white

        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [btnSpace, btnDone]
        customPickerView.addSubview(toolBar)
        countryPhoneCodePicker.frame = CGRect(x:0, y:44, width:iOSDeviceScreenSize.width, height: 200)
        countryPhoneCodePicker.backgroundColor = UIColor.white
        customPickerView.addSubview(countryPhoneCodePicker)
    }
    
    @objc func dismissPicker()
    {
        customPickerView.isHidden = true
    }
    
    func istermsSelected() -> Bool {

        return self.termsButton.isSelected
    }
    
    @IBAction func serverSwitchButtonAction(){
    
        if serverSwitchValue != 3 {
            serverSwitchValue = serverSwitchValue + 1
            return
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Dev", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            UserDefaults.standard.set("Spoint-DevDatabase", forKey: UserDefaultsKey.serverKey)
            FireBaseContants.firebaseConstant.kServerUrl = "Spoint-DevDatabase"

        }))
        
        actionSheet.addAction(UIAlertAction(title: "Prod", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            UserDefaults.standard.set("Spoint-Database", forKey: UserDefaultsKey.serverKey)
            FireBaseContants.firebaseConstant.kServerUrl = "Spoint-Database"
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{

        if textField == phoneTextField {
            let count = phoneTextField.text?.characters.count as! Int

            if count > 8 , !string.isEmpty, count < 10 {

                self.phoneTextField.text = self.phoneTextField.text! + string
                textField.resignFirstResponder()

            }
            let newLength = (textField.text?.characters.count)! + string.characters.count - range.length

            return phoneTextField.text!.validate(string: string) && newLength <= 10


        }else{

                let maxLength = 6
                let currentString: NSString = textField.text! as NSString
                let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            let count = otpTextField.text?.characters.count as! Int

            if count > 4 , !string.isEmpty {
                self.otpTextField.text = newString as! String
                textField.resignFirstResponder()

            }


                return newString.length <= maxLength
        }


        return true
    }

   

    // MARK: - CountryPhoneCodePicker Delegate

    func countryPhoneCodePicker(picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String) {
        //selectedCountryLabel.text = name + " " + countryCode + " " + phoneCode
        countryCodeLbl.text = phoneCode
        countryNameLbl.text = name
        countryImage.image = UIImage(named: countryCode.lowercased())
    }

     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "login2Dashboard" {
            //placeHolderImageView.stopAnimating()
            placeHolderImageView.isHidden = true
        }
     }


}

