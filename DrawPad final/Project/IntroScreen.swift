//
//  IntroScreen.swift
//  Project
//
//  Created by Sera Yang on 7/26/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class IntroScreen: UIViewController{
    var firstTime = true
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var titleTopHeight: NSLayoutConstraint!
    @IBOutlet weak var titleResumeHeight: NSLayoutConstraint!
    @IBOutlet weak var resumeNewHeight: NSLayoutConstraint!
    @IBOutlet weak var newInstructionsHeight: NSLayoutConstraint!
    
    
    @IBAction func resumeDrawing(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        //sets the location depending on orientation
        var height = UIScreen.main.bounds.height
        if(UIScreen.main.bounds.width > height){
            height = UIScreen.main.bounds.width
        }
        
        titleTopHeight.constant = -height * CGFloat(0.45)
        resumeNewHeight.constant = height * CGFloat(0.05)
        newInstructionsHeight.constant = height * CGFloat(0.05)
        
        
        if(firstTime){
            resumeButton.isHidden = true
            titleResumeHeight.constant = -height * CGFloat(0.05)
            
        }else{
            resumeButton.isHidden = false
            titleResumeHeight.constant = height * CGFloat(0.05)
        }

    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
