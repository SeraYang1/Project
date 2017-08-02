import UIKit

protocol SettingsViewControllerDelegate: class {
  func settingsViewControllerFinished(_ settingsViewController: SettingsViewController)
  func reset()
}

class SettingsViewController: UIViewController, UINavigationControllerDelegate {

  @IBOutlet weak var sliderBrush: UISlider!

  @IBOutlet weak var imageViewBrush: UIImageView!

  @IBOutlet weak var labelBrush: UILabel!

  @IBOutlet weak var sliderRed: UISlider!
  @IBOutlet weak var sliderGreen: UISlider!
  @IBOutlet weak var sliderBlue: UISlider!

  @IBOutlet weak var labelRed: UILabel!
  @IBOutlet weak var labelGreen: UILabel!
  @IBOutlet weak var labelBlue: UILabel!
    
    //set all constraints dynamic based on iphone/ipad
    @IBOutlet weak var imageBrushHeight: NSLayoutConstraint!
    
    @IBOutlet weak var brushRedHeight: NSLayoutConstraint!
    @IBOutlet weak var redGreenHeight: NSLayoutConstraint!
    @IBOutlet weak var greenBlueHeight: NSLayoutConstraint!
    
    @IBOutlet weak var copiedBlueHeight: NSLayoutConstraint!
    @IBOutlet weak var codeResetHeight: NSLayoutConstraint!
    
    @IBOutlet weak var colorSliderWidth: NSLayoutConstraint!
    @IBOutlet weak var brushSliderWidth: NSLayoutConstraint!
  
  var brush: CGFloat = 10.0
  var red: CGFloat = 0.0
  var green: CGFloat = 0.0
  var blue: CGFloat = 0.0
  
  weak var delegate: SettingsViewControllerDelegate?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    accessCode.text = SettingsViewController.generatedCode
    copiedTopBar.isHidden = true
    copyButton.layer.cornerRadius = 5

    var height = UIScreen.main.bounds.height
    var width = UIScreen.main.bounds.width
    colorSliderWidth.constant = width * CGFloat(0.6)
    brushSliderWidth.constant = width * CGFloat(0.55)
    
    imageBrushHeight.constant = height * CGFloat(0.05)
    
    brushRedHeight.constant = height * CGFloat(0.03)
    redGreenHeight.constant = height * CGFloat(0.03)
    greenBlueHeight.constant = height * CGFloat(0.03)
    
    copiedBlueHeight.constant = height * CGFloat(0.05)
    codeResetHeight.constant = height * CGFloat(0.1)
  }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  @IBAction func close(_ sender: AnyObject) {
    dismiss(animated: false, completion: nil)
    self.delegate?.settingsViewControllerFinished(self)
  }
    
    @IBAction func resetButton(_ sender: Any) {
        self.delegate?.reset()
        dismiss(animated: true, completion: nil)
        self.delegate?.settingsViewControllerFinished(self)
    }
    

  @IBAction func colorChanged(_ sender: UISlider) {
    red = CGFloat(sliderRed.value / 255.0)
    labelRed.text = NSString(format: "%d", Int(sliderRed.value)) as String
    green = CGFloat(sliderGreen.value / 255.0)
    labelGreen.text = NSString(format: "%d", Int(sliderGreen.value)) as String
    blue = CGFloat(sliderBlue.value / 255.0)
    labelBlue.text = NSString(format: "%d", Int(sliderBlue.value)) as String
     
    drawPreview()
  }

  @IBAction func sliderChanged(_ sender: UISlider) {
    if sender == sliderBrush {
      brush = CGFloat(sender.value)
      labelBrush.text = NSString(format: "%.2f", brush.native) as String
    }
     
    drawPreview()
  }
  
  func drawPreview() {
    UIGraphicsBeginImageContext(imageViewBrush.frame.size)
    var context = UIGraphicsGetCurrentContext()
   
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(brush)
   
    context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
    context?.move(to: CGPoint(x: 45.0, y: 45.0))
    context?.addLine(to: CGPoint(x: 45.0, y: 45.0))
    context?.strokePath()
    imageViewBrush.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
   
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
   
    sliderBrush.value = Float(brush)
    labelBrush.text = NSString(format: "%.1f", brush.native) as String
    sliderRed.value = Float(red * 255.0)
    labelRed.text = NSString(format: "%d", Int(sliderRed.value)) as String
    sliderGreen.value = Float(green * 255.0)
    labelGreen.text = NSString(format: "%d", Int(sliderGreen.value)) as String
    sliderBlue.value = Float(blue * 255.0)
    labelBlue.text = NSString(format: "%d", Int(sliderBlue.value)) as String
   
    drawPreview()
  }
    
    func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    static var generatedCode = "CODE"
    var time = 0
    var timer : Timer!
    @IBOutlet weak var copiedTopBar: UILabel!
    @IBOutlet weak var accessCode: UITextField!
    @IBOutlet weak var copyButton: UIButton!
    
    @IBAction func copyCodeButtonClicked(_ sender: Any) {
        print(SettingsViewController.generatedCode)
        UIPasteboard.general.string = accessCode.text
        copiedTopBar.isHidden = false
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(copiedDisappear)), userInfo: nil, repeats: true)
    }
    
    func copiedDisappear(){
        time = time + 1
        if(time == 2){
            copiedTopBar.isHidden = true
            timer.invalidate()
        }
    }
    
    static func setCode(s: String){
        generatedCode = s
    }


}
