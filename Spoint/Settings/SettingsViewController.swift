//
//  SettingsViewController.swift
//  Sample
//
//  Created by Rambabu Mannam on 07/11/17.
//  Copyright © 2017 Rambabu Mannam. All rights reserved.
//

import UIKit
import Firebase

import SystemConfiguration
import Social
import MaterialComponents.MaterialTextFields
import SafariServices
import MessageUI

class SettingsViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,SFSafariViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet var customPickerView: UIView!
    var pickerView = UIPickerView()
    var datePicker = UIDatePicker()
    var dataArray =  [String]()
    var isLocationSharingOn : Bool!
    var ref: DatabaseReference = Database.database().reference().child(DatabaseTable.userTable).child((Auth.auth().currentUser?.uid)!)
    var imageurl : String?
    var userprofile:User?
    @IBOutlet var profileImageButton:UIButton!
    @IBOutlet var fullNameTxtField:MDCTextField!
    @IBOutlet var emailTxtField:MDCTextField!
    @IBOutlet var dobTxtField:MDCTextField!
    @IBOutlet var genderTxtField:MDCTextField!
    @IBOutlet var mobileTxtField:MDCTextField!
    @IBOutlet var userNameTxtField:MDCTextField!
    @IBOutlet var verifyUsernameImageView:UIImageView!
var didEditPhoto =  false
    let imagePicker = UIImagePickerController()
    @IBOutlet var accountSwitch: UISwitch!
var isUsernameAvailable = false
    var genderArray = ["Male","Female","Other"]
    @IBOutlet var locationSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden =  true
        self.initialSetUp()

        fullNameTxtField.delegate = self
        emailTxtField.delegate = self
        dobTxtField.delegate = self
        genderTxtField.delegate = self
        mobileTxtField.delegate = self


        
        
    }
    @IBAction func backButtonAction(){

        self.navigationController?.popViewController(animated: true)

    }

    @IBAction func saveData(){
        if isUsernameAvailable == false {
            self.showAlertWithTitle(title: "Sorry!", message: "Username not available", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })
        }else if didEditPhoto {
            let userID = Auth.auth().currentUser?.uid
            self.showLoaderWithMessage(message: "Loading")
            let thumbnail = resizeImage(image: (profileImageButton.imageView?.image)!, targetSize: CGSize(width: 200, height: 200))
            let fileData = profileImageButton.imageView?.image?.jpeg(.high)
            var kServerUrl = UserDefaults.standard.value(forKey: UserDefaultsKey.serverKey) as? String ?? "Spoint-Database"

            var storage: Storage!
            storage = Storage.storage()
            let storageRef = storage.reference().child(kServerUrl).child("usersImage/\(userID!)/myFile")
            storageRef.putData(fileData!).observe(.success) { (snapshot) in

                let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
                var values = [String:Any]()
                if !self.emailTxtField.text!.isEmpty{
                    values[keys.emailKey] = self.emailTxtField.text!
                }
                if !self.genderTxtField.text!.isEmpty{
                    values[keys.genderKey] = self.genderTxtField.text!.lowercased()
                }
                if !self.fullNameTxtField.text!.isEmpty {
                    values[keys.fullnameKey] = self.fullNameTxtField.text!
                }
                if !self.mobileTxtField.text!.isEmpty {
                    values[keys.phoneNumberKey] = self.mobileTxtField.text!
                }
                if !self.dobTxtField.text!.isEmpty {
                    values[keys.dobKey] = self.dobTxtField.text!
                }
                if !self.userNameTxtField.text!.isEmpty {
                    values[keys.usernameKey] = self.userNameTxtField.text!
                }

                values[keys.imageUrlKey] = downloadURL ?? ""
                FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues(values, withCompletionBlock: { (errr, _) in

                    self.dismissLoader()
                    self.backButtonAction()
                })
            }
        }else{
            var values = [String:Any]()
            if !self.emailTxtField.text!.isEmpty{
                values[keys.emailKey] = self.emailTxtField.text!
            }
            if !self.genderTxtField.text!.isEmpty{
                values[keys.genderKey] = self.genderTxtField.text!.lowercased()
            }
            if !self.fullNameTxtField.text!.isEmpty {
                values[keys.fullnameKey] = self.fullNameTxtField.text!
            }
            if !self.mobileTxtField.text!.isEmpty {
                values[keys.phoneNumberKey] = self.mobileTxtField.text!
            }
            if !self.dobTxtField.text!.isEmpty {
                values[keys.dobKey] = self.dobTxtField.text!
            }
            if !self.userNameTxtField.text!.isEmpty {
                values[keys.usernameKey] = self.userNameTxtField.text!
            }
            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues(values, withCompletionBlock: { (errr, _) in

                self.dismissLoader()
                self.navigationController?.popViewController(animated: true)
            })
        }

    }
    @IBAction func imagePickerAction(){
        showActionSheet()

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
        pickerView.frame = CGRect(x:0, y:44, width:iOSDeviceScreenSize.width, height: 200)
        pickerView.backgroundColor = UIColor.white
        pickerView.delegate = self
        pickerView.dataSource = self
        customPickerView.addSubview(pickerView)
    }
    
    @IBAction func showDatePicker(){

        

        let iOSDeviceScreenSize = UIScreen.main.bounds.size
        customPickerView.isHidden = false
        //Adding toolbar
        let toolBar = UIToolbar(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(iOSDeviceScreenSize.width), height: CGFloat(44)))
        toolBar.sizeToFit()
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.RedColor()

        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donedatePicker))
        btnDone.tintColor = UIColor.white

        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [btnSpace, btnDone]
        customPickerView.addSubview(toolBar)
        datePicker.frame = CGRect(x:0, y:44, width:iOSDeviceScreenSize.width, height: 200)
        datePicker.backgroundColor = UIColor.white
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.date(from: dobTxtField.text!)
        if date != nil {
            datePicker.date = date!
        }else {
            let oneYear = TimeInterval(60 * 60 * 24 * 365)
            let newYears = Date(timeIntervalSince1970: oneYear*20)

            datePicker.date = newYears
        }
        datePicker.datePickerMode = .date

        datePicker.maximumDate = Date()
        customPickerView.addSubview(datePicker)
    }
    @objc func donedatePicker(){

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dobTxtField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        customPickerView.isHidden = true

    }
    @objc func dismissPicker()
    {
        customPickerView.isHidden = true
        if (genderTxtField.text?.isEmpty)! {
            genderTxtField.text =  genderArray [0]
        }
    }
    func initialSetUp()
    {


        isLocationSharingOn = true
        if !ReachabilityManager.shared.isNetworkAvailable {
            self.showAlertWithTitle(title: "Sorry!", message: "No Internet", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })

        }else{
            self.showLoaderWithMessage(message: "Loading")
            FireBaseContants.firebaseConstant.getCurrentUser { (user) in

                self.dismissLoader()

                DispatchQueue.main.async() {

                    self.dataArray[0] = (user.fullname )
                    self.fullNameTxtField.text = (user.fullname)

                    if user.gender.lowercased() == "male"{
                        self.dataArray[1] = "Male"
                        self.genderTxtField.text = "Male"
                    }else{
                        self.dataArray[1] = "Female"
                        self.genderTxtField.text = "Female"
                    }
                    self.dataArray[2] = (user.city )
                    self.dataArray[3] = (user.email )
                    self.emailTxtField.text = user.email
                    self.mobileTxtField.text = user.phone
                    self.dobTxtField.text = user.dob
                    self.userNameTxtField.text =  user.name
                    self.userprofile = user
                    self.profileImageButton.kf.setImage(with: self.userprofile?.profilePic, for: .normal)
                    self.profileImageButton.clipsToBounds = true
                    self.isUsernameAvailable = true

                    //self.accountSwitch.isOn = (self.userprofile?.accountTypePrivate)!
                    //self.accountSwitch.isOn = (FireBaseContants.firebaseConstant.currentUserInfo?.accountTypePrivate)!


                }
            }
        }


        dataArray = ["","","","","Log Out"]
        self.title = "Settings"
        /*let nib = UINib(nibName: "SettingsImageTableViewCell", bundle: nil)
        let nib1 = UINib(nibName: "SettingsContentTableViewCell", bundle: nil)
        let nib2 = UINib(nibName: "SettingsLocationSharingTableViewCell", bundle: nil)
        self.settingsTableView.register(nib, forCellReuseIdentifier: "SettingImageCell")
        self.settingsTableView.register(nib1, forCellReuseIdentifier: "SettingsContentCell")
        self.settingsTableView.register(nib2, forCellReuseIdentifier: "LocationSharingCell")*/
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self


    }
    @IBAction func facebookConnect(){

        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {

            let vc = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
            vc!.add(UIImage(named: "sp-marker.png"))
            vc!.add(URL(string: "https://itunes.apple.com/in/app/spoint/id1193946807?mt=8"))
            vc!.setInitialText("Discover new friends using SPOINT APP. Download app from \("https://itunes.apple.com/in/app/spoint/id1193946807?mt=8").")
            self.present(vc!, animated: true, completion: nil)
        }else{

            self.showAlertWithTitle(title: "ERROR", message: "Account not configured", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })
        }


       /* FacebookClass.sharedInstance().getFacebookFriends(viewController: self, successHandler: { (response) in
            print(response)

//            let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
//            content.contentURL = NSURL(string: "www.spoint.live")
//            content.contentTitle = "Invite"
//            content.contentDescription = "Share"
//            content.imageURL = NSURL(string: "url")
//            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)

        }, failHandler: { (failResponse) in

            print(failResponse)
        })*/

    }

    @IBAction func twitterConnect() {

        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
        {
            let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
            vc!.add(UIImage(named: "sp-marker.png"))
            vc!.add(URL(string: "https://itunes.apple.com/in/app/spoint/id1193946807?mt=8"))
            vc!.setInitialText("Discover new friends using SPOINT APP. Download app from \("https://itunes.apple.com/in/app/spoint/id1193946807?mt=8").")
            self.present(vc!, animated: true, completion: nil)
        }else{

            self.showAlertWithTitle(title: "ERROR", message: "Account not configured", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })
        }


    /*TwitterClass.sharedInstance().loginWithTwitter(viewController: self, successHandler: { (response) in
        print(response)

        }, failHandler: { (failResponse) in
            print(failResponse)


        })*/
    }

    @IBAction func shareToContact(){


        if (MFMessageComposeViewController.canSendText()) {

        let controller = MFMessageComposeViewController()

        controller.body = "Discover new friends using SPOINT APP. Download app from \("https://itunes.apple.com/in/app/spoint/id1193946807?mt=8")."
        controller.messageComposeDelegate = self

        self.present(controller, animated: true, completion: nil)

        }

    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }
    @IBAction func logoutButtonAction(){


        self.showAlertWithTitle(title: "Logout!", message: "Do you want to logout?", buttonCancelTitle: "Cancel", buttonOkTitle: "Ok") { (index) in

            if index == 1 {
                User.logOutUser { (t) in

                    UserDefaults.standard.set(nil, forKey: UserDefaultsKey.phoneNoKey)

                }
                //TODO: stop location service
                FireBaseContants.firebaseConstant.USER_REF().removeAllObservers()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    @IBAction func openSafariController(){

        let safariVC = SFSafariViewController(url: NSURL(string: "https://docs.google.com/document/d/1LDB-GSDw0M2O8YuUU1_3ouAU8DxSkjOVb4KeKrWMpPM/edit?usp=sharing")! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    //MARK: Picker Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderArray[row]
    }
    //Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        genderTxtField.text = genderArray[row]

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchAccountAction(sender:UISwitch){

        FireBaseContants.firebaseConstant.currentUserInfo?.accountTypePrivate = sender.isOn

        FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.accountTypeKey:sender.isOn], withCompletionBlock: { (errr, _) in

        })
    }

    @objc func switchIsChanged(sender: UISwitch) {
        if sender.isOn {
            self.isLocationSharingOn = true
 FireBaseContants.firebaseConstant.currentUserInfo?.locationState = true

            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.locationStateKey:true], withCompletionBlock: { (errr, _) in

            })
        } else {
            self.isLocationSharingOn = false
//            location?.stop()
//            location?.locationManager.stopUpdatingLocation()
//            location?.stopWatchPosition()
//            self.location?.changePace(false)

            FireBaseContants.firebaseConstant.currentUserInfo?.locationState = false

 FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.locationStateKey: false], withCompletionBlock: { (errr, _) in

            })
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == fullNameTxtField {
            fullNameTxtField.resignFirstResponder()
            mobileTxtField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == genderTxtField {
            textField.resignFirstResponder()
            self.showPicker()
            return false
        }else if textField == dobTxtField {
            textField.resignFirstResponder()
            self.showDatePicker()
            return false
        }else{
            self.dismissPicker()
            self.donedatePicker()
            return true
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{

        if textField == mobileTxtField {

            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString

            let count = mobileTxtField.text?.characters.count as! Int
            if count > 9 , !string.isEmpty {
                self.mobileTxtField.text = newString as! String
                emailTxtField.becomeFirstResponder()
            }
            return newString.length <= maxLength
        }else if textField == self.userNameTxtField, (textField.text?.count)! > 2 {

                checkUserNameAvailability(text: textField.text! + string)
        }else if textField == self.userNameTxtField {
            self.verifyUsernameImageView.image = UIImage(named: "close_red")
             isUsernameAvailable = false

        }

        return true
    }

    func checkUserNameAvailability(text: String) {
        
        let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.usernameKey ).queryEqual(toValue:text.trimmingCharacters(in: .whitespaces) )
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            if snapshot.children.allObjects.count == 0 && text != nil {
                
                self.verifyUsernameImageView.image = UIImage(named: "tick")
                self.isUsernameAvailable = true

            }else{
                self.verifyUsernameImageView.image = UIImage(named: "close_red")
                self.isUsernameAvailable = false

            }
        })
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)

    }
    func camera()
    {

        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.present(imagePicker, animated: true, completion: nil)
    }

    func photoLibrary()
    {
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)

    }

    
}

//MARK: UITableView Delegate Methods
extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return dataArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        }else if indexPath.section == 5 {
            return 60
        }
        else if indexPath.section == 6 {
            return 200
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingImageCell") as! SettingsImageTableViewCell
            cell.selectionStyle = .none

            if (userprofile != nil){
                cell.userImageView.kf.setImage(with: userprofile?.profilePic)
            }
            return cell
        }else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationSharingCell") as! SettingsLocationSharingTableViewCell
            cell.locationSharingSwitch.addTarget(self, action: #selector(switchIsChanged), for: UIControlEvents.valueChanged)
            cell.accountTypeSwitch.addTarget(self, action: #selector(switchAccountAction(sender:)), for: UIControlEvents.valueChanged)

            if self.userprofile != nil{
                cell.locationSharingSwitch.isOn = (self.userprofile?.locationState)!
                cell.accountTypeSwitch.isOn = (self.userprofile?.accountTypePrivate)!

            }

            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsContentCell") as! SettingsContentTableViewCell
            cell.contentLabel.text = dataArray[indexPath.section - 1] as? String
            if indexPath.section == 1 {
                cell.contentLabel.font =  UIFont.systemFont(ofSize: 20)
                cell.contentLabel.textColor = UIColor.red
            }
            else if indexPath.section == 5 {
                cell.bgView.isHidden = false
                cell.bgView.layer.borderWidth = 2
                cell.bgView.layer.borderColor = UIColor.red.cgColor
                cell.contentView.backgroundColor = UIColor.init(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)

            }else{
                cell.bgView.isHidden = true
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 5 {

            self.showAlertWithTitle(title: "Logout!", message: "Do you want to logout?", buttonCancelTitle: "Cancel", buttonOkTitle: "Ok") { (index) in

                if index == 1 {
                    User.logOutUser { (t) in

                        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.phoneNoKey)

                    }
                    //TODO: stop location service
                    FireBaseContants.firebaseConstant.USER_REF().removeAllObservers()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }

        }
    }
    
}

extension SettingsViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        self.didEditPhoto = true
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageButton.setImage(pickedImage, for: .normal)

        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
