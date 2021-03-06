//
//  RotationLock.swift
//  Project
//
//  Created by Sera Yang on 7/24/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class InstructionPage: UIViewController{
    
    @IBOutlet weak var instructionsTopSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        self.modalPresentationStyle = .fullScreen
        var height = UIScreen.main.bounds.height
        if(UIScreen.main.bounds.width > height){
            height = UIScreen.main.bounds.width
        }
        
        instructionsTopSpace.constant = -height * CGFloat(0.35)
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
