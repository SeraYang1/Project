//
//  Canvas.swift
//  NXDrawKit
//
//  Created by Nicejinux on 7/14/16.
//  Copyright © 2016 Nicejinux. All rights reserved.
//

import UIKit

@objc public protocol CanvasDelegate
{
    @objc optional func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?)
    @objc optional func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?)
    
    func brush() -> Brush?
}


open class Canvas: UIView, UITableViewDelegate
{
    open weak var delegate: CanvasDelegate?
    
    fileprivate var canvasId: String?
    
    fileprivate var mainImageView = UIImageView()
    fileprivate var tempImageView = UIImageView()
    fileprivate var backgroundImageView = UIImageView()
    
    fileprivate var brush = Brush()
    fileprivate let session = Session()
    fileprivate var drawing = Drawing()
    fileprivate let path = UIBezierPath()
    fileprivate let scale = UIScreen.main.scale

    fileprivate var saved = false
    fileprivate var pointMoved = false
    fileprivate var pointIndex = 0
    fileprivate var points = [CGPoint?](repeating: CGPoint.zero, count: 5)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(canvasId: String? = nil, backgroundImage image: UIImage? = nil) {
        super.init(frame: CGRect.zero)
        self.path.lineCapStyle = .round
        self.canvasId = canvasId
        self.backgroundImageView.image = image
        if image != nil {
            session.appendBackground(Drawing(stroke: nil, background: image))
        }
        self.initialize()
    }
    
    // MARK: - Private Methods
    fileprivate func initialize() {
        self.backgroundColor = UIColor.white
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.contentMode = .scaleAspectFit
        self.backgroundImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
        
        self.addSubview(self.mainImageView)
        self.mainImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]

        self.addSubview(self.tempImageView)
        self.tempImageView.autoresizingMask = [.flexibleHeight ,.flexibleWidth]
    }
    
    fileprivate func compare(_ image1: UIImage?, isEqualTo image2: UIImage?) -> Bool {
        if (image1 == nil && image2 == nil) {
            return true
        } else if (image1 == nil || image2 == nil) {
            return false
        }
        
        let data1 = UIImagePNGRepresentation(image1!)
        let data2 = UIImagePNGRepresentation(image2!)

        if (data1 == nil || data2 == nil) {
            return false
        }

        return (data1! == data2)
    }
    
    fileprivate func currentDrawing() -> Drawing {
        return Drawing(stroke: self.mainImageView.image, background: self.backgroundImageView.image)
    }
    
    fileprivate func updateByLastSession() {
        let lastSession = self.session.lastSession()
        self.mainImageView.image = lastSession?.stroke
        self.backgroundImageView.image = lastSession?.background
    }
    
    fileprivate func didUpdateCanvas() {
        let mergedImage = self.mergePathsAndImages()
        let currentDrawing = self.currentDrawing()
        self.delegate?.canvas?(self, didUpdateDrawing: currentDrawing, mergedImage: mergedImage)
    }
    
    fileprivate func didSaveCanvas() {
        let mergedImage = self.mergePathsAndImages()
        self.delegate?.canvas?(self, didSaveDrawing: self.drawing, mergedImage: mergedImage)
    }
    
    fileprivate func isStrokeEqual() -> Bool {
        return self.compare(self.drawing.stroke, isEqualTo: self.mainImageView.image)
    }
    
    fileprivate func isBackgroundEqual() -> Bool {
        return self.compare(self.drawing.background, isEqualTo: self.backgroundImageView.image)
    }
    

    // MARK: - Override Methods
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.saved = false
        self.pointMoved = false
        self.pointIndex = 0
        self.brush = (self.delegate?.brush())!
        
        let touch = touches.first!
        self.points[0] = touch.location(in: self)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*
         * Smooth Freehand Drawing on iOS
         * http://code.tutsplus.com/tutorials/ios-sdk_freehand-drawing--mobile-13164
         *
         */

        let touch = touches.first!
        let currentPoint = touch.location(in: self)
        self.pointMoved = true
        self.pointIndex += 1
        self.points[self.pointIndex] = currentPoint
        
        if self.pointIndex == 4 {
            // move the endpoint to the middle of the line joining the second control point of the first Bezier segment
            // and the first control point of the second Bezier segment
            self.points[3] = CGPoint(x: (self.points[2]!.x + self.points[4]!.x)/2.0, y: (self.points[2]!.y + self.points[4]!.y) / 2.0)

            // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            self.path.move(to: self.points[0]!)
            self.path.addCurve(to: self.points[3]!, controlPoint1: self.points[1]!, controlPoint2: self.points[2]!)
            
            // replace points and get ready to handle the next segment
            self.points[0] = self.points[3]
            self.points[1] = self.points[4]
            self.pointIndex = 1
        }
        
        self.strokePath()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.pointMoved {   // touchesBegan -> touchesEnded : just touched
            self.path.move(to: self.points[0]!)
            self.path.addLine(to: self.points[0]!)
            self.strokePath()
        }
        
        self.mergePaths()      // merge all paths
        self.didUpdateCanvas()
        
        self.path.removeAllPoints()
        self.pointIndex = 0
    }
    
    fileprivate func strokePath() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.path.lineWidth = (self.brush.width / self.scale)
        self.brush.color.withAlphaComponent(self.brush.alpha).setStroke()
        
        if self.brush.isEraser {
            // should draw on screen for being erased
            self.mainImageView.image?.draw(in: self.bounds)
        }
        
        self.path.stroke(with: brush.blendMode, alpha: 1)

        let targetImageView = self.brush.isEraser ? self.mainImageView : self.tempImageView
        targetImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    fileprivate func mergePaths() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.mainImageView.image?.draw(in: self.bounds)
        self.tempImageView.image?.draw(in: self.bounds)
        
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.session.append(self.currentDrawing())
        self.tempImageView.image = nil
        
        UIGraphicsEndImageContext()
    }
    
    fileprivate func mergePathsAndImages() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        if self.backgroundImageView.image != nil {
            let rect = self.centeredBackgroundImageRect()
            self.backgroundImageView.image?.draw(in: rect)            // draw background image
        }
        
        self.mainImageView.image?.draw(in: self.bounds)               // draw stroke
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()   // merge
        
        UIGraphicsEndImageContext()
        
        return mergedImage!
    }
    
    fileprivate func centeredBackgroundImageRect() -> CGRect {
        if self.frame.size.equalTo((self.backgroundImageView.image?.size)!) {
            return self.frame
        }
        
        let selfWidth = self.frame.width
        let selfHeight = self.frame.height
        let imageWidth = self.backgroundImageView.image?.size.width
        let imageHeight = self.backgroundImageView.image?.size.height
        
        let widthRatio = selfWidth / imageWidth!
        let heightRatio = selfHeight / imageHeight!
        let scale = min(widthRatio, heightRatio)
        let resizedWidth = scale * imageWidth!
        let resizedHeight = scale * imageHeight!
        
        var rect = CGRect.zero
        rect.size = CGSize(width: resizedWidth, height: resizedHeight)
        
        if selfWidth > resizedWidth {
            rect.origin.x = (selfWidth - resizedWidth) / 2
        }
        
        if selfHeight > resizedHeight {
            rect.origin.y = (selfHeight - resizedHeight) / 2
        }
        
        return rect
    }
    
    
    // MARK: - Public Methods
    open func update(_ backgroundImage: UIImage?) {
        self.backgroundImageView.image = backgroundImage
        self.session.append(self.currentDrawing())
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }
    
    open func undo() {
        self.session.undo()
        self.updateByLastSession()
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }

    open func redo() {
        self.session.redo()
        self.updateByLastSession()
        self.saved = self.canSave()
        self.didUpdateCanvas()
    }
    
    open func clear() {
        self.session.clear()
        self.updateByLastSession()
        self.saved = true
        self.didUpdateCanvas()
    }
    
    open func save() {
        self.drawing.stroke = self.mainImageView.image?.copy() as? UIImage
        self.drawing.background = self.backgroundImageView.image
        self.saved = true
        self.didSaveCanvas()
    }
    
    open func canUndo() -> Bool {
        return self.session.canUndo()
    }

    open func canRedo() -> Bool {
        return self.session.canRedo()
    }

    open func canClear() -> Bool {
        return self.session.canReset()
    }

    open func canSave() -> Bool {
        return !(self.isStrokeEqual() && self.isBackgroundEqual())
    }
}
