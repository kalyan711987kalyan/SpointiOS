//
//  SExtension.swift
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD
import KRActivityIndicatorView
import GoogleMaps
class SExtension: NSObject {

    
}
extension String {
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return self.filter {okayChars.contains($0)}.trimmingCharacters(in: .whitespaces)
    }
}
//: Decodable Extension
extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

//: Encodable Extension
extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}
public extension UINavigationBar {

    /// SwifterSwift: Pop ViewController with completion handler.
    ///
    /// - Parameter completion: optional completion handler (default is nil).


    /// SwifterSwift: Make navigation controller's navigation bar transparent.
    ///
    /// - Parameter tint: tint color (default is .white).
    public func makeTransparent(withTint tint: UIColor = .white) {
        isTranslucent = true
        backgroundColor = .clear
        barTintColor = .clear
        setBackgroundImage(UIImage(), for: .default)
        tintColor = tint
        titleTextAttributes = [.foregroundColor: tint]
        shadowImage = UIImage()
    }

}
extension UIColor
{
    class func RedColor() -> UIColor
    {
        return UIColor(red: 253.0/255.0, green: 0.0/255.0, blue: 0/255.0, alpha: 1.0)
    }

    class func TitleColor() -> UIColor
    {
        return UIColor(red: 154.0/255.0, green: 143.0/255.0, blue: 169.0/255.0, alpha:1.0)
    }

    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
            let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
            return color
        }


}
extension UITextField {

    func underlined(){
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true

    }

    func numericOnlyavailable(string:String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }

    func setMaxLimit(max:Int) -> Bool{

        return true
    }

    func addBorderBottom(height: CGFloat, color: UIColor) {

        let border = UIView()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color
        self.addSubview(border)
    }
}
extension String {

    func validate(string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }

    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count)) != nil
    }

   
}
extension UIImageView {
    public func imageFromServerURL(urlString: String) {

        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in

            if(error != nil){

                return
            }

            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image

            })

        }).resume()
    }
}
extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

class SSBadgeButton: UIButton {

    var badgeLabel = UILabel()

    var badge: String? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }

    public var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }

    public var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }

    public var badgeFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }

    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToButon(badge: badge)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToButon(badge: nil)
    }

    func addBadgeToButon(badge: String?) {
        badgeLabel.text = badge
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        let badgeSize = badgeLabel.frame.size

        let height = max(18, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)

        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)

            let x = (Double(bounds.size.width) - 10 + horizontal!)
            let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
            badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            let x = self.frame.width - CGFloat((width / 2.0))
            let y = CGFloat(-(height / 2.0))
            badgeLabel.frame = CGRect(x: x, y: y+10.0, width: CGFloat(width), height: CGFloat(height))
        }

        badgeLabel.layer.cornerRadius = badgeLabel.frame.height/2
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        badgeLabel.isHidden = badge != nil ? false : true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBadgeToButon(badge: nil)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
    }
}

extension UIButton {
    public func imageFromServerURL(urlString: String) {

        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in

            if(error != nil){

                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.setImage(image, for: .normal)

            })


        }).resume()
    }
}

extension UIViewController {

    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
    
    func showLoaderWithMessage(message:String){
        KRProgressHUD.show(withMessage: message)
    }

    func dismissLoader()  {
        KRProgressHUD.dismiss()
    }
    func showAlertWithTitle(title: String, message: String, buttonCancelTitle: String,buttonOkTitle: String, completion: @escaping (Int?)->Void) {

        let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if buttonOkTitle.characters.count>0 {
            let okAction: UIAlertAction = UIAlertAction(title: buttonOkTitle, style: .default) { action -> Void in

                completion(1)
            }
            actionSheetController.addAction(okAction)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: buttonCancelTitle, style: .cancel) { action -> Void in
            completion(2)

        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func showEmptyMessage(message:String, tableview:UITableView) {

        let messageLabel = UILabel(frame: CGRect(x:0,y:0,width:tableview.bounds.size.width, height: tableview.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        messageLabel.sizeToFit()
        tableview.backgroundView = messageLabel;
        tableview.separatorStyle = .none;
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0,width:newSize.width,height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    public func timeAgoSince(_ date: Date) -> String {

        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])

        /*if let year = components.year, year >= 2 {
            return "\(year) years ago"
        }

        if let year = components.year, year >= 1 {
            return "Last year"
        }

        if let month = components.month, month >= 2 {
            return "\(month) months ago"
        }

        if let month = components.month, month >= 1 {
            return "Last month"
        }

        if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        }

        if let week = components.weekOfYear, week >= 1 {

            return "Last week"
        }

        if let day = components.day, day >= 2 {
            return "\(day) days ago"
        }*/
        
        if let day = components.day, day > 1 {
            return date.getDateStringWithFormate(formate: "dd.MM.yyyy")
        }

        if let day = components.day, day == 1, let hour = components.hour, hour > 24 {
            //return date.getDateStringWithFormate(formate: "dd.MM.yyyy")
            return "yesterday"

        }

        if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        }

        if let hour = components.hour, hour >= 1 {
            return "An hour ago"
        }

        if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        }

        if let minute = components.minute, minute >= 1 {
            return "A minute ago"
        }

        if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        }

        return "Just now"

    }

    func forTailingZero(temp: Double) -> String{
        var tempVar = String(format: "%g", temp)
        return tempVar
    }

    func resetChildViewController() {

        if self.childViewControllers.count > 0{
            let viewControllers:[UIViewController] = self.childViewControllers
            for viewContoller in viewControllers{
                viewContoller.willMove(toParentViewController: nil)
                viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParentViewController()
            }
        }
    }

     func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }

}
class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        
    }
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }


    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
//    var jpeg: Data? {
//        return UIImageJPEGRepresentation(self, 0.7)
//    }
    var png: Data? {
        return UIImagePNGRepresentation(self)
    }
}
extension GMSCircle {
    func bounds () -> GMSCoordinateBounds {
        func locationMinMax(positive : Bool) -> CLLocationCoordinate2D {
            let sign:Double = positive ? 1 : -1
            let dx = sign * self.radius  / 6378000 * (180/M_PI)
            let lat = position.latitude + dx
            let lon = position.longitude + dx / cos(position.latitude * M_PI/180)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        return GMSCoordinateBounds(coordinate: locationMinMax(positive: true),
                                   coordinate: locationMinMax(positive: false))
    }

    var bound: GMSCoordinateBounds {
        return [0, 90, 180, 270].map {
            GMSGeometryOffset(position, radius, $0)
            }.reduce(GMSCoordinateBounds()) {
                $0.includingCoordinate($1)
        }
    }
}
extension GMSMapView {
    func mapStyle(withFilename name: String, andType type: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
                self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
}
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "HelveticaNeue-Medium", size: 16)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)

        return self
    }

    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {

        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "Helvetica", size: 16)!]

        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)

        return self
    }
}
extension Date{

    func getDateString() -> String {
        let date = self
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        let result = formatter.string(from: date)
        return result
    }

    func getDateStringWithFormate(formate:String) -> String {
        let date = self
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        let result = formatter.string(from: date)
        return result
    }

    func getDateFormatWithString(formate:String, dateString:String) -> Date {

        let formatter = DateFormatter()
        formatter.dateFormat = formate
        let result = formatter.date(from: dateString)
        return result!
    }

    func getDateStringFormate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: self)
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "HH:mm a"
        // again convert your date to string
        let datestring = formatter.string(from: yourDate!)
        return datestring
    }

    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }

}

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true

        
    }
}

extension UIView {

    // MARK: - Corners
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    // MARK: - Shadows
    @IBInspectable var shadowRadius: Double {
        get {
            return Double(self.layer.shadowRadius)
        }
        set {
            self.layer.shadowRadius = CGFloat(newValue)
        }
    }

    // The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1] range will give undefined results. Animatable.
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }

    // The shadow offset. Defaults to (0, -3). Animatable.
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }

    // The color of the shadow. Defaults to opaque black. Colors created from patterns are currently NOT supported. Animatable.
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.shadowColor ?? UIColor.clear.cgColor)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }

    // Off - Will show shadow | On - Won't show shadow.
    @IBInspectable var masksToBounds: Bool {
        get {
            return self.layer.masksToBounds
        }

        set {
            self.layer.masksToBounds = newValue
        }
    }
    // MARK: - BorderWidth
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    // MARK: - BorderColor
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }

}
extension UIWindow {
    func topViewController() -> UIViewController! {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
protocol ReusableView: class {}

extension ReusableView where Self: UIView {

    static var reuseIdentifier: String {
        return String(describing: self)
    }

}

protocol NibLoadableView: class { }

extension NibLoadableView where Self: UIView {

    static var nibName: String {
        // notice the new describing here
        // now only one place to refactor if describing is removed in the future
        return String(describing: self)
    }

}

// Now all UITableViewCells have the nibName variable
// you can also apply this to UICollectionViewCells if you have those
// Note that if you have some cells that DO NOT load from a Nib vs some that do,
// extend the cells individually vs all of them as below!
// In my project, all cells load from a Nib.
extension UITableViewCell: NibLoadableView { }
extension UITableViewCell: ReusableView { }
extension UITableView {

    func register<T: UITableViewCell>(_: T.Type) where T: ReusableView, T: NibLoadableView {

        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }
}
