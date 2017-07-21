//
//  DownloadedSketchpad.swift
//  Project
//
//  Created by Sera Yang on 7/11/17.
//  Copyright © 2017 com.Project. All rights reserved.
//


import UIKit
import NXDrawKit
import RSKImageCropper
import AVFoundation
import MobileCoreServices

class DownloadedSketchpad: UIViewController
{
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
        
        let button = UIButton(frame: CGRect(x: self.view.frame.height/30, y: self.view.frame.height/20, width: 70, height: 28))
        if #available(iOS 10.0, *) {
            button.backgroundColor = UIColor(displayP3Red: 188.0/255.0, green: 232.0/255.0, blue: 1.0, alpha: 1)
        } else {
            button.backgroundColor = UIColor.red
        }
        button.setTitle("Back", for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    func goBack(sender: UIButton!) {
        //TODO - save the picture?? 
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccessCodePage") as! AccessCodePage
        self.present(viewController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initialize() {
        self.setupPalette()
        self.setupToolBar()
        self.setupCanvas()

    }
    
    func setupPalette() {
        self.view.backgroundColor = UIColor.white
        
        let paletteView = Palette()
        paletteView.delegate = self
        paletteView.setup()
        self.view.addSubview(paletteView)
        self.paletteView = paletteView
        let paletteHeight = paletteView.paletteHeight()
        paletteView.frame = CGRect(x: 0, y: self.view.frame.height - paletteHeight, width: self.view.frame.width, height: paletteHeight)
    }
    
    //Double tap the tool bar to hide the palette
    func hidePalette() {
        let height = (self.paletteView?.frame)!.height * 0.25
        let startY = self.view.frame.height - height
        self.toolBar?.frame = CGRect(x: 0, y: startY, width: self.view.frame.width, height: height)
        self.toolBar?.frame = CGRect(x: CGFloat(0), y: self.view.frame.height - 60, width: self.view.frame.width, height: CGFloat(60))
        self.paletteView?.frame = CGRect(x: 0, y: self.view.frame.height, width: 0, height: 0) //move it out of the screen
        self.toolBar?.addGestureRecognizer(doubleTap(toShowPalette: true))

    }
    
    //Double tap the tool bar to show the palette
    func showPalette() {
        let paletteHeight = paletteView?.paletteHeight()
        self.paletteView?.frame = CGRect(x: 0, y: self.view.frame.height - paletteHeight!, width: self.view.frame.width, height: paletteHeight!)
        let height = (self.paletteView?.frame)!.height * 0.25
        let startY = self.view.frame.height - (paletteView?.frame)!.height - height
        self.toolBar?.frame = CGRect(x: 0, y: startY, width: self.view.frame.width, height: height)
        self.toolBar?.addGestureRecognizer(doubleTap(toShowPalette: false))
    }
    
    //Return a GestureRecognizer for when user double taps the toolbar to either show or hide the palette
    func doubleTap(toShowPalette: Bool) -> UITapGestureRecognizer {
        var doubleTap: UITapGestureRecognizer!
        if toShowPalette {
            doubleTap = UITapGestureRecognizer(target: self, action: #selector(DownloadedSketchpad.showPalette))
        }
        
        else {
             doubleTap = UITapGestureRecognizer(target: self, action: #selector(DownloadedSketchpad.hidePalette))
        }
        
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }
    
    func setupToolBar() {
        let height = (self.paletteView?.frame)!.height * 0.25
        let startY = self.view.frame.height - (paletteView?.frame)!.height - height
        let toolBar = ToolBar()
        toolBar.frame = CGRect(x: 0, y: startY, width: self.view.frame.width, height: height)
        toolBar.undoButton?.addTarget(self, action: #selector(DownloadedSketchpad.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(DownloadedSketchpad.onClickRedoButton), for: .touchUpInside)
        toolBar.loadButton?.addTarget(self, action: #selector(DownloadedSketchpad.onClickLoadButton), for: .touchUpInside)
        toolBar.clearButton?.addTarget(self, action: #selector(DownloadedSketchpad.onClickClearButton), for: .touchUpInside)
        toolBar.loadButton?.isEnabled = true
        self.view.addSubview(toolBar)
        self.toolBar = toolBar
        self.toolBar?.addGestureRecognizer(doubleTap(toShowPalette: false))
    }
    
    func setupCanvas() {
      
        let canvasView = Canvas()

        canvasView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - (self.toolBar?.frame.height)!)
        canvasView.delegate = self

        self.view.addSubview(canvasView)
        self.canvasView = canvasView
        self.view.bringSubview(toFront: self.paletteView!)
        self.view.bringSubview(toFront: self.toolBar!)
    }
    
    func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
    
    func onClickUndoButton() {
        self.canvasView?.undo()
    }
    
    func onClickRedoButton() {
        self.canvasView?.redo()
    }
    
    func onClickLoadButton() {
        self.showActionSheetForPhotoSelection()
    }
    
    func onClickSaveButton() {
        self.canvasView?.save()
    }
    
    func onClickClearButton() {
        self.canvasView?.clear()
    }
    
    
    // MARK: - Image and Photo selection
    fileprivate func showActionSheetForPhotoSelection() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Photo from Album", "Take a Photo")
        actionSheet.show(in: self.view)
    }
    
    fileprivate func showPhotoLibrary () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeImage)]
        
        self.present(picker, animated: true, completion: nil)
    }
    
    fileprivate func showCamera() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch (status) {
        case .notDetermined:
            self.presentImagePickerController()
            break
        case .restricted, .denied:
            self.showAlertForImagePickerPermission()
            break
        case .authorized:
            self.presentImagePickerController()
            break
        }
    }
    
    fileprivate func showAlertForImagePickerPermission() {
        let message = "If you want to use camera, you should allow app to use.\nPlease check your permission"
        let alert = UIAlertView(title: "", message: message, delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Allow")
        alert.show()
    }
    
    fileprivate func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    fileprivate func presentImagePickerController() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = [String(kUTTypeImage)]
            self.present(picker, animated: true, completion: nil)
        } else {
            let message = "This device doesn't support a camera"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafeRawPointer)       {
        if didFinishSavingWithError != nil {
            let message = "Saving failed"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        } else {
            let message = "Saved successfuly"
            let alert = UIAlertView(title:"", message:message, delegate:nil, cancelButtonTitle:nil, otherButtonTitles:"Ok")
            alert.show()
        }
    }
}


// MARK: - CanvasDelegate
extension DownloadedSketchpad: CanvasDelegate
{
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        self.updateToolBarButtonStatus(canvas)
    }
    
    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
        // you can save merged image
        //        if let pngImage = image?.asPNGImage() {
        //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        }
        
        // you can save strokeImage
        //        if let pngImage = drawing.stroke?.asPNGImage() {
        //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        }
        
        //        self.updateToolBarButtonStatus(canvas)
        
        // you can share your image with UIActivityViewController
        if let pngImage = image?.asPNGImage() {
            let activityViewController = UIActivityViewController(activityItems: [pngImage], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension DownloadedSketchpad: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        let selectedImage : UIImage = image
        picker.dismiss(animated: true, completion: { [weak self] in
            let cropper = RSKImageCropViewController(image:selectedImage, cropMode:.square)
            cropper.delegate = self
            self?.present(cropper, animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - RSKImageCropViewControllerDelegate
extension DownloadedSketchpad: RSKImageCropViewControllerDelegate
{
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.canvasView?.update(croppedImage)
        controller.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIActionSheetDelegate
extension DownloadedSketchpad: UIActionSheetDelegate
{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if (actionSheet.cancelButtonIndex == buttonIndex) {
            return
        }
        
        if buttonIndex == 1 {
            self.showPhotoLibrary()
        } else if buttonIndex == 2 {
            self.showCamera()
        }
    }
}


// MARK: - UIAlertViewDelegate
extension DownloadedSketchpad: UIAlertViewDelegate
{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (alertView.cancelButtonIndex == buttonIndex) {
            return
        } else {
            self.openSettings()
        }
    }
}


// MARK: - PaletteDelegate
extension DownloadedSketchpad: PaletteDelegate
{
    //    func didChangeBrushColor(color: UIColor) {
    //
    //    }
    //
    //    func didChangeBrushAlpha(alpha: CGFloat) {
    //
    //    }
    //
    //    func didChangeBrushWidth(width: CGFloat) {
    //
    //    }
    
    
    // tag can be 1 ... 12
    func colorWithTag(_ tag: NSInteger) -> UIColor? {
        if tag == 4 {
            // if you return clearColor, it will be eraser
            return UIColor.clear
        }
        return nil
    }
    
    // tag can be 1 ... 4
    //    func widthWithTag(tag: NSInteger) -> CGFloat {
    //        if tag == 1 {
    //            return 5.0
    //        }
    //        return -1
    //    }
    // tag can be 1 ... 3
    //    func alphaWithTag(tag: NSInteger) -> CGFloat {
    //        return -1
    //    }
}
