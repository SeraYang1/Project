//
//  ViewController.swift
//  DrawPad
//
//  Created by Jean-Pierre Distler on 13.11.14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    let ref = Database.database().reference()
    let authRef = Auth.auth()
    var userId: String!
    var strokeCount: Int!
    var coordinateCount: Int!
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Authenticate user
        if (authRef.currentUser == nil) {
            print("no user")
            authRef.signInAnonymously(completion: { (user, error) in
                if error != nil {
                    print(error)
                    print("failed")
                    return
                }
                print ("User logged in anonymously with uid: " + user!.uid)
                self.userId = user!.uid
            })
            
            }
            else {
            print("Already signed in")
            self.userId = authRef.currentUser?.uid
        }
        userId = "I0jrHfkx4USQmaLJldEtDTtXaqF2"
        let newUserRef = self.ref.child("users").child(userId)
        newUserRef.setValue("ok") //TODO replace with password and figure out sign out.
   
        
        //passes the id to settings so it can be copied as access code
        SettingsViewController.setCode(s: userId)

        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            self.ref.child(userId).child("screen_width").setValue(view.frame.height)
            self.ref.child(userId).child("screen_height").setValue(view.frame.width)
        }
        else { //portrait
            self.ref.child(userId).child("screen_height").setValue(view.frame.height)
            self.ref.child(userId).child("screen_width").setValue(view.frame.width)
        }
        self.ref.child("users").child(userId).onDisconnectRemoveValue()
        self.ref.child(userId).onDisconnectRemoveValue()

        strokeCount = 0
        coordinateCount = 1
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    @IBAction func pencilPressed(_ sender: AnyObject) {
        
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        (red, green, blue) = colors[index]
        
//        if index == colors.count - 1 {
//            opacity = 1.0
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        strokeCount = strokeCount + 1
        print("here")
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("brush_width").setValue(brushWidth)
//        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("opacity").setValue(opacity)
        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("red").setValue(red * 255)
        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("green").setValue(green * 255)
        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("blue").setValue(blue * 255)


        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("x".appending(String(coordinateCount))).setValue(Float(lastPoint.x))
        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("y".appending(String(coordinateCount))).setValue(Float(lastPoint.y))
        coordinateCount = coordinateCount + 1
        
        
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        // 3
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        // 4
        context?.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = 1
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 6
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("x".appending(String(coordinateCount))).setValue(Float(lastPoint.x))
        self.ref.child(userId).child("strokes").child(String(strokeCount)).child("y".appending(String(coordinateCount))).setValue(Float(lastPoint.y))
        coordinateCount = coordinateCount + 1
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        self.ref.child(userId).child("current_stroke").setValue(strokeCount) //last one saved in db
        coordinateCount = 1         //resets in preparation for next batch of coord data
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "settings"){
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.delegate = self
            settingsViewController.brush = brushWidth
//            settingsViewController.opacity = opacity
            settingsViewController.red = red
            settingsViewController.green = green
            settingsViewController.blue = blue
        }
        
        if(segue.identifier == "Intro"){
            let introViewController = segue.destination as! IntroScreen
            introViewController.firstTime = false
        }
    }
    
    
    
    
}

extension ViewController: SettingsViewControllerDelegate {
    func settingsViewControllerFinished(_ settingsViewController: SettingsViewController) {
        self.brushWidth = settingsViewController.brush
//        self.opacity = settingsViewController.opacity
        self.red = settingsViewController.red
        self.green = settingsViewController.green
        self.blue = settingsViewController.blue
    }
    
    
    
    func reset() {
        mainImageView.image = nil
        self.ref.child(userId).child("strokes").setValue(nil)
        strokeCount = 0
        
        self.ref.child(userId).child("current_stroke").setValue(strokeCount)
    }
}

