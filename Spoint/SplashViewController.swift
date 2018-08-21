//
//  SplashViewController.swift
//  Spoint
//
//  Created by kalyan on 16/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet var placeHolderImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

       // placeHolderImageView.animationImages = [#imageLiteral(resourceName: "Splash1.png"),#imageLiteral(resourceName: "Splash2.png"),#imageLiteral(resourceName: "Splash3.png"),#imageLiteral(resourceName: "Splash4.png"),#imageLiteral(resourceName: "Splash5.png"),#imageLiteral(resourceName: "Splash0.png")]
        //placeHolderImageView.animationDuration = 1
        //placeHolderImageView.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
