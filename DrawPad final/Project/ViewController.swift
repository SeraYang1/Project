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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
        
        override func viewWillAppear(_ animated: Bool) { //TODO remove the thing if user id exists
            if self.userId == nil {
            self.userId = self.ref.child("sharing").child(appDelegate.getUID()).childByAutoId().key //access code
            self.ref.child("sharing").child(appDelegate.getUID()).child(self.userId).setValue("")
            self.ref.child("sharing").child(appDelegate.getUID()).onDisconnectRemoveValue() //clean up after disconnected
            self.ref.child(self.userId).onDisconnectRemoveValue()
            
            //passes the id to settings so it can be copied as access code
            SettingsViewController.setCode(s: self.userId)
            
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                self.ref.child(self.userId).child("screen_width").setValue(self.view.frame.height)
                self.ref.child(self.userId).child("screen_height").setValue(self.view.frame.width)
            }
            else { //portrait
                self.ref.child(self.userId).child("screen_height").setValue(self.view.frame.height)
                self.ref.child(self.userId).child("screen_width").setValue(self.view.frame.width)
            }
            
            
            self.strokeCount = 0
            self.coordinateCount = 1
            }
        }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
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
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            strokeCount = strokeCount + 1
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self.view)
            }
            self.ref.child(userId).child("strokes").child(String(strokeCount)).child("brush_width").setValue(brushWidth)
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
    
