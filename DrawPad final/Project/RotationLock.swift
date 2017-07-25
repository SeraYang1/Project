//
//  RotationLock.swift
//  Project
//
//  Created by Sera Yang on 7/24/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class RotationLock: UIViewController{
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
