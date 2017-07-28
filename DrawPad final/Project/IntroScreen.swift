//
//  IntroScreen.swift
//  Project
//
//  Created by Sera Yang on 7/26/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class IntroScreen: UIViewController{
    var test = "123"
    var firstTime = true
    @IBOutlet weak var resumeButton: UIButton!
    
//    override func viewWillAppear(_ animated: Bool) {
//        if(firstTime){
//            resumeButton.isHidden = true
//        }else{
//            resumeButton.isHidden = false
//        }
//    }
    
    @IBAction func resumeDrawing(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        if(firstTime){
            resumeButton.isHidden = true
        }else{
            resumeButton.isHidden = false
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
