//
//  SketchpadViewController.swift
//  Project
//
//  Created by Janice Chan on 7/8/17.
//  Copyright © 2017 com.Project. All rights reserved.
//

import UIKit


class SketchpadViewController: UIViewController {
    var code: Int!
    var codeLabel: UILabel!
    var pen: UIView!
    var color: UIColor!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        //            addUIElements()
        
    }
    
    //        func addUIElements() {
    //            codeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
    //            codeLabel.center = CGPoint(x: 150, y: view.frame.height - 10)
    //            codeLabel.text = "Code: ".appending(String(code))
    //            view.addSubview(codeLabel)
    //
    //            color = UIColor.black
    //        }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        pen = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    //        if let location = touches.first?.location(in: view) {
    //            pen.center = location
    //            switch color {
    //            case UIColor.blue:
    //                return
    //
    //            default:
    //                pen.backgroundColor = .black
    //                view.addSubview(pen)
    //            }
    //
    //        }
    //    }
    
    //needs a lot of refinement
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        pen = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: 0.5))
        for touch in touches {
            let location = touch.location(in:view)
            pen.center = location
            
            switch color {
            case UIColor.blue:
                return
                
            default:
                pen.backgroundColor = .black
                view.addSubview(pen)
            }
            
        }
        
    }
    
    
}
