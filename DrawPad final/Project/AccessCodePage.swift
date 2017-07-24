//
//  AccessCodePage.swift
//  Project
//
//  Created by Sera Yang on 7/13/17.
//  Copyright © 2017 com.Project. All rights reserved.
//

import UIKit

class AccessCodePage : UIViewController {
    //TODO - set this code to access code
    var generatedCode = "Generated Code"
    var time = 0
    var timer : Timer!
    @IBOutlet weak var copiedTopBar: UIView!
    @IBOutlet weak var accessCode: UITextField!
    @IBOutlet weak var copyButton: UIButton!
    
    override func viewDidLoad() {
        accessCode.text = generatedCode
        copiedTopBar.isHidden = true
        copyButton.layer.cornerRadius = 5
    }
    
    @IBAction func copyCodeButtonClicked(_ sender: Any) {
        print(generatedCode)
        UIPasteboard.general.string = accessCode.text
        copiedTopBar.isHidden = false
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(copiedDisappear)), userInfo: nil, repeats: true)
    }
    
    func copiedDisappear(){
        time = time + 1
        if(time == 3){
            copiedTopBar.isHidden = true
            timer.invalidate()
        }
    }
}
