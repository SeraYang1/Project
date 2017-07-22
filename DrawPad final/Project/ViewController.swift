//
//  ViewController.swift
//  DrawPad
//
//  Created by Jean-Pierre Distler on 13.11.14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var tempImageView: UIImageView!

  var lastPoint = CGPoint.zero
  var red: CGFloat = 0.0
  var green: CGFloat = 0.0
  var blue: CGFloat = 0.0
  var brushWidth: CGFloat = 10.0
  var opacity: CGFloat = 1.0
  var swiped = false
  var jsonData: [String: Any] = [:]
  var coordinates: [Float] = [] //format: [x1, y1, x2, y2...]
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
    // Do any additional setup after loading the view, typically from a nib.
    jsonData.updateValue(view.frame.width, forKey: "screen_width")
    jsonData.updateValue(view.frame.height, forKey: "screen_height")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Actions

  @IBAction func reset(_ sender: AnyObject) {
    mainImageView.image = nil
    jsonData.removeAll()
    jsonData.updateValue("true", forKey: "reset")
    sendJSONToServer(jsonObject: jsonData)
  }

  @IBAction func pencilPressed(_ sender: AnyObject) {
    
    var index = sender.tag ?? 0
    if index < 0 || index >= colors.count {
      index = 0
    }
    
    (red, green, blue) = colors[index]
    
    if index == colors.count - 1 {
      opacity = 1.0
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    swiped = false
    if let touch = touches.first {
      lastPoint = touch.location(in: self.view)
    }
    coordinates = []
    jsonData.updateValue(brushWidth, forKey: "opacity")
    jsonData.updateValue(opacity, forKey: "brush_size")
    jsonData.updateValue(red, forKey: "red")
    jsonData.updateValue(green, forKey: "green")
    jsonData.updateValue(blue, forKey: "blue")
    coordinates.append(Float(lastPoint.x))
    coordinates.append(Float(lastPoint.y))

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
    tempImageView.alpha = opacity
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
    coordinates.append(Float(lastPoint.x))
    coordinates.append(Float(lastPoint.y))

  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("ended")
    if !swiped {
      // draw a single point
      drawLineFrom(lastPoint, toPoint: lastPoint)
    }
    
    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(mainImageView.frame.size)
    mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
    tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: opacity)
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    tempImageView.image = nil
    jsonData.updateValue(coordinates, forKey: "coordinates")
    sendJSONToServer(jsonObject: jsonData)
  }
    
    func sendJSONToServer(jsonObject: [String:Any]) {
        if JSONSerialization.isValidJSONObject(jsonObject) { // True
            do {
                let rawData = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
                print(jsonData)
                //TODO send to server
            } catch {
                print("error")
            }
        }
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let settingsViewController = segue.destination as! SettingsViewController
    settingsViewController.delegate = self
    settingsViewController.brush = brushWidth
    settingsViewController.opacity = opacity
    settingsViewController.red = red
    settingsViewController.green = green
    settingsViewController.blue = blue
  }
  
}

extension ViewController: SettingsViewControllerDelegate {
  func settingsViewControllerFinished(_ settingsViewController: SettingsViewController) {
    self.brushWidth = settingsViewController.brush
    self.opacity = settingsViewController.opacity
    self.red = settingsViewController.red
    self.green = settingsViewController.green
    self.blue = settingsViewController.blue
  }
}

