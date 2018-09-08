//
//  RegisterViewController.swift
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class RegisterViewController: UIViewController,UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var fullnameField: UITextField!
    @IBOutlet var cityField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var dobField : UITextField!

    @IBOutlet var genderTxtField: UITextField!
    let imagePicker = UIImagePickerController()
    @IBOutlet var pickerButton: UIButton!
    @IBOutlet var placeholderImage: UIImageView!
    @IBOutlet var tickButton:UIButton!
    
    @IBOutlet var customPickerView: UIView!
    var pickerView = UIPickerView()
    var genderArray = ["Male","Female","Other"]
    var isUsernameAvailable = false

    var isNewUser = true
    var didUploadProfile  = false
    var ref: DatabaseReference = Database.database().reference()
    var shouldUploadProfile =  true
    @objc var datePicker: UIDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        dateFormatter.dateFormat = "MM/dd/yyyy"
        FireBaseContants.firebaseConstant.getCurrentUser { (user) in
              DispatchQueue.main.async {

                self.usernameField.text = user.name
                self.fullnameField.text = user.fullname
                self.dobField.text = user.age
                self.cityField.text = user.city
                self.emailField.text = user.email
               
                self.didUploadProfile = true
                
                self.pickerButton.kf.setImage(with: user.profilePic, for: .normal)
                self.genderTxtField.text = user.gender
                
                self.dobField.text = user.dob
                self.isUsernameAvailable = true

                self.shouldUploadProfile = false
                self.isNewUser = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func imagePickerAction(){
         showActionSheet()

    }
    @IBAction func submitButtonAction(){

        if !ReachabilityManager.shared.isNetworkAvailable {
            self.showAlertWithTitle(title: "Sorry!", message: "No Internet", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })
            return
        }
        
        let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.usernameKey ).queryEqual(toValue: self.usernameField.text ?? "xx")
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
           if snapshot.children.allObjects.count == 0 || !self.isNewUser{
                self.registerUser()
           }else{
            self.showAlertWithTitle(title: "Sorry!", message: "Username already exist!", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })
            }
        })

       
    }
    
    func registerUser() {
        let userID = Auth.auth().currentUser?.uid
        if ((self.dobField.text?.isEmpty)! || (self.cityField.text?.isEmpty)! || (self.usernameField.text?.isEmpty)! || (self.fullnameField.text?.isEmpty)! || (self.emailField.text?.isEmpty)! ){
            self.showAlertWithTitle(title: "Please enter all fields", message: "", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in })
            return
        }
        if !(self.emailField.text?.isValidEmail())! {
            self.showAlertWithTitle(title: "Please enter valid email", message: "", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in  })
            return
        }
        
        if didUploadProfile == false {
            self.showAlertWithTitle(title: "Please upload profile image", message: "", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in  })
            return
        }
        if isUsernameAvailable == false {
            self.showAlertWithTitle(title: "Sorry!", message: "Username not available", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in
            })
        }
        
        //        if Int(self.ageField.text!)! < 17 || Int(self.ageField.text!)! > 110 {
        //            self.showAlertWithTitle(title: "Age should be greater than 18", message: "", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in  })
        //            return
        //        }
        
        self.showLoaderWithMessage(message: "Loading")
        if shouldUploadProfile  {
            var kServerUrl = UserDefaults.standard.value(forKey: UserDefaultsKey.serverKey) as? String ?? "Spoint-Database"

            let fileData = pickerButton.imageView?.image?.jpeg(.medium)
            var storage: Storage!
            storage = Storage.storage()
            let storageRef = storage.reference().child(kServerUrl).child("usersImage/\(userID!)/myFile")
            storageRef.putData(fileData!).observe(.success) { (snapshot) in
                
                
                
                let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
                var token = ""
                if let fcmtoken = InstanceID.instanceID().token() {
                    token = fcmtoken
                }
                var gender = self.genderTxtField.text ?? "Male"
                let username = self.usernameField.text?.trimmingCharacters(in: .whitespaces)

                
                let values = [keys.emailKey: self.emailField.text!, keys.usernameKey: username!.lowercased(),keys.dobKey:self.dobField.text!,keys.genderKey:gender,keys.cityKey:self.cityField.text ?? "",keys.fullnameKey: self.fullnameField.text!,keys.imageUrlKey:downloadURL ?? "",keys.phoneNumberKey: UserDefaults.standard.value(forKeyPath: UserDefaultsKey.phoneNoKey) as! String,keys.idKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.tokenKey:token,keys.locationStateKey:true,keys.deviceTypeKey:0] as [String : Any]
                FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues(values, withCompletionBlock: { (errr, _) in
                    
                    self.dismissLoader()
                    if errr == nil {
                        self.performSegue(withIdentifier: "dashboardSegue", sender: self)
                    }
                })
            }
        }else {
            var token = ""
            if let fcmtoken = InstanceID.instanceID().token() {
                token = fcmtoken
            }

            
            var gender = self.genderTxtField.text ?? "Male"
            let username = self.usernameField.text?.trimmingCharacters(in: .whitespaces)
            let values = [keys.emailKey: self.emailField.text!, keys.usernameKey: username!.lowercased(),keys.dobKey:self.dobField.text!,keys.genderKey:gender,keys.cityKey:self.cityField.text ?? "",keys.fullnameKey: self.fullnameField.text!,keys.phoneNumberKey: UserDefaults.standard.value(forKeyPath: UserDefaultsKey.phoneNoKey) as! String,keys.idKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.tokenKey:token,keys.locationStateKey:true,keys.deviceTypeKey:0] as [String : Any]
            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues(values, withCompletionBlock: { (errr, _) in
                
                self.dismissLoader()
                if errr == nil {
                    self.performSegue(withIdentifier: "dashboardSegue", sender: self)
                }
            })
            
        }

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
    
    func showPickerView(){

        self.view.endEditing(true)
        customPickerView.isHidden = false
        //Adding toolbar
        let toolBar = UIToolbar(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: customPickerView.frame.size.width, height: CGFloat(44)))
        toolBar.sizeToFit()
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.red
        
        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissPicker))
        btnDone.tintColor = UIColor.white
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [btnSpace, btnDone]
        customPickerView.addSubview(toolBar)

        
            datePicker.frame = CGRect(x:0, y:44, width:customPickerView.frame.size.width, height: 200)
            datePicker.datePickerMode = .date
            datePicker.maximumDate = Date()
            datePicker.backgroundColor = UIColor.white
        datePicker.addTarget(self, action: #selector(datePicker_Btn), for: .valueChanged)
            customPickerView.addSubview(datePicker)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.date(from: dobField.text!)
        if date != nil {
            datePicker.date = date!
        }else {
            let oneYear = TimeInterval(60 * 60 * 24 * 365)
            let newYears = Date(timeIntervalSince1970: oneYear*20)
            
            datePicker.date = newYears
        }
        datePicker.datePickerMode = .date
    }
    
    @IBAction func showGenderPicker() {
        let iOSDeviceScreenSize = UIScreen.main.bounds.size
        
        customPickerView.isHidden = false
        //Adding toolbar
        let toolBar = UIToolbar(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(iOSDeviceScreenSize.width), height: CGFloat(44)))
        toolBar.sizeToFit()
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.RedColor()
        
        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissGenderPicker))
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
    
    @objc func datePicker_Btn() {
        dobField.text = dateFormatter.string(from: datePicker.date)

    }
    @objc func dismissPicker()
    {
        customPickerView.isHidden = true
        dobField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func dismissGenderPicker(){
        customPickerView.isHidden = true
        guard let text = self.genderTxtField.text else {
            return
        }
        if text.count == 0 {
            genderTxtField.text = genderArray[0]
        }
    }
    
    func checkUserNameAvailability(text: String) {

        let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.usernameKey ).queryEqual(toValue:text.trimmingCharacters(in: .whitespaces) )
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            if snapshot.children.allObjects.count == 0 && text != nil {

                self.tickButton.setImage(UIImage(named: "tick"), for: .normal)
                self.isUsernameAvailable = true

            }else{
                self.tickButton.setImage(UIImage(named: "close_red"), for: .normal)
                self.isUsernameAvailable = false

            }
        })
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
    
    //MARK: TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dobField {
            showPickerView()
            return false
        }else if textField == genderTxtField {
            self.showGenderPicker()
            return false
        }else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.usernameField {
            checkUserNameAvailability(text: textField.text!)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{

        if textField == self.usernameField, (textField.text?.count)! > 2 {
            checkUserNameAvailability(text: textField.text! + string)
        }else if textField == self.usernameField {
            self.tickButton.setImage(UIImage(named: "close_red"), for: .normal)
            isUsernameAvailable = false

        }
        /*if textField == ageField {

            let maxLength = 2
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString

            let count = ageField.text?.characters.count as! Int

            if count > 0 , !string.isEmpty {
                self.ageField.text = newString as! String
                textField.resignFirstResponder()

            }


            return newString.length <= maxLength
        }*/

        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension RegisterViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){

        self.didUploadProfile = true
        self.shouldUploadProfile = true

        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pickerButton.setImage(pickedImage, for: .normal)
            placeholderImage.image = nil
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
