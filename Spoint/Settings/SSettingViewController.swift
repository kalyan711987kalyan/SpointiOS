//
//  SSettingViewController.swift
//  Spoint
//
//  Created by kalyan on 20/12/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import UserNotifications
import SafariServices

class SSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,SFSafariViewControllerDelegate, UIGestureRecognizerDelegate {

    var arrayList = [String]()
    var imageList = [String]()
    var themeArray = ["Standardstyle","Retrostyle","Nightstyle"]
    @IBOutlet var customPickerView: UIView!
    var pickerView = UIPickerView()
    @IBOutlet var tableview:UITableView!
    @IBOutlet var bgImageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        bgImageView.image = kAppDelegate?.bgImage

        // Do any additional setup after loading the view.
        arrayList = ["Account Settings","Display Settings","Push Notifications","Location Settings","Favourite","Terms & Conditions","Privacy Policy"]
        imageList = ["settingsblack","Contactblack","Contactblack"]
        tableview.register(SettingsSwitchTableViewCell.self)
        tableview.register(SettingsGeneralTableViewCell.self)


    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        tableview.reloadData()
    }
    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
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

        kAppDelegate?.mapThemeName = themeArray[0]
        UserDefaults.standard.set(themeArray[0], forKey: "theme")

    }

    @IBAction func openSafariController(){

        let safariVC = SFSafariViewController(url: NSURL(string: "https://drive.google.com/open?id=1VSqz7UhOjfPp3avVF101rb1uFwc_g46L")! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    @objc func dismissPicker()
    {
        customPickerView.isHidden = true
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKind(of: DashboardViewController.self) {

                self.navigationController!.popToViewController(controller, animated: true)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayList.count
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        if indexPath.row == 2 || indexPath.row == 3  {
            let cell:SettingsSwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchTableViewCell") as! SettingsSwitchTableViewCell

            cell.titleLabel.text = arrayList[indexPath.row]
            cell.settingsSwitch.tag = indexPath.row
            if indexPath.row == 3{
                if FireBaseContants.firebaseConstant.currentUserInfo != nil{
                    cell.settingsSwitch.isOn = (FireBaseContants.firebaseConstant.currentUserInfo?.locationState)!
                }
            }else{

                cell.settingsSwitch.isOn = UIApplication.shared.isRegisteredForRemoteNotifications
            }
            cell.settingsSwitch.addTarget(self, action: #selector(switchAccountAction(sender:)), for: UIControlEvents.valueChanged)


            return cell
        }
        let cell:SettingsGeneralTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsGeneralTableViewCell") as! SettingsGeneralTableViewCell

        cell.titleLabel.text = arrayList[indexPath.row]
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 1 {
            //let vc = storyboard?.instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
            //self.navigationController?.pushViewController(vc, animated: true)
            showPicker()
        }else if indexPath.row == 4 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "FavouriteViewController") as! FavouriteViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 5 {
            let safariVC = SFSafariViewController(url: NSURL(string:"https://drive.google.com/open?id=1p_l9_ZdiO4GKqBtUZTnZ8syJAVwJ7vV5")! as URL)
            //
            //Terms
            self.present(safariVC, animated: true, completion: nil)
            safariVC.delegate = self
        }else if indexPath.row == 6 {
            self.openSafariController()
        }
    }
    
    @IBAction func spintLiveBtnAction(){
        let safariVC = SFSafariViewController(url: NSURL(string: "https://www.spoint.live")! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }

    @objc func switchAccountAction(sender:UISwitch){

        if sender.tag == 2 {
            if sender.isOn {
                //FireBaseContants.firebaseConstant.currentUserInfo?.locationState = true
                //ref = Database.database().reference()
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: {_, _ in

                            print(UIApplication.shared.isRegisteredForRemoteNotifications)

                    })
                } else {
                    let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(settings)
                    print(UIApplication.shared.isRegisteredForRemoteNotifications)



                }
                FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.notificationStatusKey:true], withCompletionBlock: { (errr, _) in  })
            } else {
                //FireBaseContants.firebaseConstant.currentUserInfo?.locationState = false
                UIApplication.shared.unregisterForRemoteNotifications()

                print(UIApplication.shared.isRegisteredForRemoteNotifications)
                FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.notificationStatusKey: false], withCompletionBlock: { (errr, _) in

                })
            }

        }else if sender.tag == 3 {

            FireBaseContants.firebaseConstant.currentUserInfo?.locationState = sender.isOn

            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.accountTypeKey:sender.isOn], withCompletionBlock: { (errr, _) in

            })
        }

    }

    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

    //MARK: Picker Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themeArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return themeArray[row]
    }
    //Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        kAppDelegate?.mapThemeName = themeArray[row]
        UserDefaults.standard.set(themeArray[row], forKey: "theme")

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
