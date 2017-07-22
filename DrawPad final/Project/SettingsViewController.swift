import UIKit

protocol SettingsViewControllerDelegate: class {
  func settingsViewControllerFinished(_ settingsViewController: SettingsViewController)
}

class SettingsViewController: UIViewController {

  @IBOutlet weak var sliderBrush: UISlider!
  @IBOutlet weak var sliderOpacity: UISlider!

  @IBOutlet weak var imageViewBrush: UIImageView!
  @IBOutlet weak var imageViewOpacity: UIImageView!

  @IBOutlet weak var labelBrush: UILabel!
  @IBOutlet weak var labelOpacity: UILabel!

  @IBOutlet weak var sliderRed: UISlider!
  @IBOutlet weak var sliderGreen: UISlider!
  @IBOutlet weak var sliderBlue: UISlider!

  @IBOutlet weak var labelRed: UILabel!
  @IBOutlet weak var labelGreen: UILabel!
  @IBOutlet weak var labelBlue: UILabel!
  
  var brush: CGFloat = 10.0
  var opacity: CGFloat = 1.0
  var red: CGFloat = 0.0
  var green: CGFloat = 0.0
  var blue: CGFloat = 0.0
  
  weak var delegate: SettingsViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func close(_ sender: AnyObject) {
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
    } else {
      opacity = CGFloat(sender.value)
      labelOpacity.text = NSString(format: "%.2f", opacity.native) as String
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
   
    UIGraphicsBeginImageContext(imageViewBrush.frame.size)
    context = UIGraphicsGetCurrentContext()
   
    context?.setLineCap(CGLineCap.round)
    context?.setLineWidth(20)
    context?.move(to: CGPoint(x: 45.0, y: 45.0))
    context?.addLine(to: CGPoint(x: 45.0, y: 45.0))
   
    context?.setStrokeColor(red: red, green: green, blue: blue, alpha: opacity)
    context?.strokePath()
    imageViewOpacity.image = UIGraphicsGetImageFromCurrentImageContext()
   
    UIGraphicsEndImageContext()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
   
    sliderBrush.value = Float(brush)
    labelBrush.text = NSString(format: "%.1f", brush.native) as String
    sliderOpacity.value = Float(opacity)
    labelOpacity.text = NSString(format: "%.1f", opacity.native) as String
    sliderRed.value = Float(red * 255.0)
    labelRed.text = NSString(format: "%d", Int(sliderRed.value)) as String
    sliderGreen.value = Float(green * 255.0)
    labelGreen.text = NSString(format: "%d", Int(sliderGreen.value)) as String
    sliderBlue.value = Float(blue * 255.0)
    labelBlue.text = NSString(format: "%d", Int(sliderBlue.value)) as String
   
    drawPreview()
  }

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}
