//
//  ViewController.swift
//  MyFaceTracker
//
//  Created by camtasia on 2016-03-11.
//  Copyright © 2016 camtasia. All rights reserved.
//

import UIKit
import FaceTracker

class ViewController: UIViewController, FaceTrackerViewControllerDelegate {
    @IBOutlet var facesMenu: UIView!
    @IBOutlet var eyeLeftMenu: UIView!
    @IBOutlet var eyeRightMenu: UIView!
    @IBOutlet var mouthMenu: UIView!
    @IBOutlet var noseMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    var subMenuViews = [String: [UIView]]()
    var currentSubView: UIView!
    
    @IBOutlet var faceTrackerContainerView: UIView!
    weak var faceTrackerViewController: FaceTrackerViewController?
    var faces = [String: UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "faceTrackerEmbed") {
            faceTrackerViewController = segue.destinationViewController as? FaceTrackerViewController
            faceTrackerViewController!.delegate = self
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        faceTrackerViewController!.startTracking { () -> Void in
        }
    }
    
    func updateViewForFeature(feature: String, index: Int, point: CGPoint, bgColor: UIColor) {
        
        let frame = CGRectMake(point.x-2, point.y-2, 4.0, 4.0)
        
        if subMenuViews[feature] == nil {
            subMenuViews[feature] = [UIView]()
        }
        
        if index < subMenuViews[feature]!.count {
            subMenuViews[feature]![index].frame = frame
            subMenuViews[feature]![index].hidden = false
            subMenuViews[feature]![index].backgroundColor = bgColor
        } else {
            let newView = UIView(frame: frame)
            newView.backgroundColor = bgColor
            newView.hidden = false
            self.view.addSubview(newView)
            subMenuViews[feature]! += [newView]
        }
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    func faceTrackerDidUpdate(points: FacePoints?) {
        for face in faces {
            if let points = points {
                updateView(points, forFace: face)
            } else {
                face.1.hidden = true
            }
        }
    }
    
    func updateView(points: FacePoints, forFace face: (String,UIImageView)) {
        let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
        let eyeToEyeCenter = CGPointMake((points.leftEye[0].x + points.rightEye[5].x) / 2, (points.leftEye[0].y + points.rightEye[5].y) / 2)
        
        var viewWidth = 2.0 * eyeCornerDist
        var viewHeight = (face.1.image!.size.height / face.1.image!.size.width) * viewWidth
        
        face.1.transform = CGAffineTransformIdentity
        
        var newPos = CGPoint()
        if face.0.rangeOfString("PatchLeft") != nil {
            newPos.x = points.leftEye[0].x - 25
            newPos.y = points.leftEye[0].y - 50
            viewWidth = eyeCornerDist/2
            viewHeight = viewWidth
        } else if face.0.rangeOfString("PatchRight") != nil {
            newPos.x = points.rightEye[0].x - 25
            newPos.y = points.rightEye[0].y - 50
            viewWidth = eyeCornerDist/2
            viewHeight = viewWidth
        } else if face.0.rangeOfString("Teeth") != nil {
            newPos.x = points.outerMouth[0].x - 35
            newPos.y = points.outerMouth[0].y - 55
            viewWidth = eyeCornerDist
            viewHeight = viewWidth * 0.9
        } else if face.0.rangeOfString("Nose") != nil {
            newPos.x = eyeToEyeCenter.x - viewWidth / 4
            newPos.y = points.nose[0].y - 70
            viewWidth = eyeCornerDist
            viewHeight = viewWidth * 0.9
        } else {
            if face.0.rangeOfString("Mummy2") != nil {
                newPos.x = eyeToEyeCenter.x - viewWidth / 2
                newPos.y = eyeToEyeCenter.y - viewWidth * 0.53
            } else if face.0.rangeOfString("Mummy3") != nil {
                newPos.x = eyeToEyeCenter.x - viewWidth / 2
                newPos.y = eyeToEyeCenter.y - viewWidth * 0.7
            } else if face.0.rangeOfString("Mummy4") != nil {
                newPos.x = eyeToEyeCenter.x - viewWidth / 2
                newPos.y = eyeToEyeCenter.y - viewWidth * 0.55
            } else if face.0.rangeOfString("Mummy5") != nil {
                newPos.x = eyeToEyeCenter.x - viewWidth / 2
                newPos.y = eyeToEyeCenter.y - viewWidth * 0.27
            } else {
                newPos.x = eyeToEyeCenter.x - viewWidth / 2.15
                newPos.y = eyeToEyeCenter.y - viewWidth * 0.65
            }
        }
        
        face.1.frame = CGRectMake(newPos.x, newPos.y, viewWidth, viewHeight)
        face.1.hidden = false
        
        setAnchorPoint(CGPointMake(0.5, 1.0), forView: face.1)
        
        let angle = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
        face.1.transform = CGAffineTransformMakeRotation(angle)
    }
    
    @IBAction func flipCamera(sender: UIButton) {
        faceTrackerViewController?.swapCamera()
    }

    @IBAction func onFaces(sender: UIButton) {
        toggleMenu(sender, menuView: facesMenu)
    }

    @IBAction func onEyeLeft(sender: UIButton) {
        toggleMenu(sender, menuView: eyeLeftMenu)
    }
    
    @IBAction func onEyeRight(sender: UIButton) {
        toggleMenu(sender, menuView: eyeRightMenu)
    }
    
    @IBAction func onMouth(sender: UIButton) {
        toggleMenu(sender, menuView: mouthMenu)
    }
    
    @IBAction func onNose(sender: UIButton) {
        toggleMenu(sender, menuView: noseMenu)
    }
    
    func toggleMenu(sender: UIButton, menuView: UIView) {
        replaceBottomMenu(menuView)
    }
    
    func replaceBottomMenu(menuView: UIView) {
        bottomMenu.addSubview(menuView)
        
        let bottomConstraint = menuView.topAnchor.constraintEqualToAnchor(bottomMenu.bottomAnchor)
        let leftConstraint = menuView.leftAnchor.constraintEqualToAnchor(bottomMenu.leftAnchor)
        let rightConstraint = menuView.rightAnchor.constraintEqualToAnchor(bottomMenu.rightAnchor)
        let heightConstraint = menuView.heightAnchor.constraintEqualToConstant(75)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        bottomMenu.layoutIfNeeded()
        
        menuView.alpha = 0
        UIView.animateWithDuration(0.4) {
            menuView.alpha = 1.0
        }
        currentSubView = menuView
    }
    
    func hideSubMenu(menuView: UIView) {
        UIView.animateWithDuration(0.4, animations: {
            menuView.alpha = 0
        }) { completed in
            if completed == true {
                menuView.removeFromSuperview()
            }
        }
    }

    func setImage(name: String, category: String) {
        if let f = faces[name] {
            faces.removeValueForKey(name)
            f.removeFromSuperview()
        } else {
            removeAllOtherOfSameType(category)
            let newView = UIImageView()
            newView.image = UIImage(named: name)
            view.insertSubview(newView, aboveSubview: faceTrackerContainerView)
            faces[name] = newView
        }
    }
    
    func removeAllOtherOfSameType(name: String) {
        for face in faces {
            if((face.0.rangeOfString(name)) != nil) {
                face.1.removeFromSuperview()
                faces.removeValueForKey(face.0)
            }
        }
    }

    @IBAction func onBackButton(sender: UIButton) {
        currentSubView.removeFromSuperview()
    }
    
    func onOverlay(imageName: String, category: String, menu: UIView) {
        setImage(imageName, category: category)
        hideSubMenu(menu)
    }
    
    @IBAction func onLeftEyePatch(sender: UIButton) {
        onOverlay("PatchLeft1", category: "PatchLeft", menu: eyeLeftMenu)
    }
    
    @IBAction func onLeft2EyePatch(sender: UIButton) {
        onOverlay("PatchLeft2", category: "PatchLeft", menu: eyeLeftMenu)
    }
    
    @IBAction func onLeft3EyePatch(sender: UIButton) {
        onOverlay("PatchLeft3", category: "PatchLeft", menu: eyeLeftMenu)
    }
    
    @IBAction func onLeft4EyePatch(sender: UIButton) {
        onOverlay("PatchLeft4", category: "PatchLeft", menu: eyeLeftMenu)
    }
    
    @IBAction func onLeft5EyePatch(sender: UIButton) {
        onOverlay("PatchLeft5", category: "PatchLeft", menu: eyeLeftMenu)
    }

    @IBAction func onRightEyePatch(sender: UIButton) {
        onOverlay("PatchRight1", category: "PatchRight", menu: eyeRightMenu)
    }
    
    @IBAction func onRight2EyePatch(sender: UIButton) {
        onOverlay("PatchRight2", category: "PatchRight", menu: eyeRightMenu)
    }
    
    @IBAction func onRight3EyePatch(sender: UIButton) {
        onOverlay("PatchRight3", category: "PatchRight", menu: eyeRightMenu)
    }
    
    @IBAction func onRight4EyePatch(sender: UIButton) {
        onOverlay("PatchRight4", category: "PatchRight", menu: eyeRightMenu)
    }
    
    @IBAction func onRight5EyePatch(sender: UIButton) {
        onOverlay("PatchRight5", category: "PatchRight", menu: eyeRightMenu)
    }
    
    @IBAction func onMummy(sender: UIButton) {
        onOverlay("Mummy1", category: "Mummy", menu: facesMenu)
    }
    
    @IBAction func onMummy2(sender: UIButton) {
        onOverlay("Mummy2", category: "Mummy", menu: facesMenu)
    }
    
    @IBAction func onMummy3(sender: UIButton) {
        onOverlay("Mummy3", category: "Mummy", menu: facesMenu)
    }
    
    @IBAction func onMummy4(sender: UIButton) {
        onOverlay("Mummy4", category: "Mummy", menu: facesMenu)
    }
    
    @IBAction func onMummy5(sender: UIButton) {
        onOverlay("Mummy5", category: "Mummy", menu: facesMenu)
    }
    
    @IBAction func onTeeth(sender: UIButton) {
        onOverlay("Teeth1", category: "Teeth", menu: mouthMenu)
    }

    @IBAction func onMouth2(sender: UIButton) {
        onOverlay("Teeth2", category: "Teeth", menu: mouthMenu)
    }

    @IBAction func onMouth3(sender: UIButton) {
        onOverlay("Teeth3", category: "Teeth", menu: mouthMenu)
    }

    @IBAction func onMouth4(sender: UIButton) {
        onOverlay("Teeth4", category: "Teeth", menu: mouthMenu)
    }

    @IBAction func onMouth5(sender: UIButton) {
        onOverlay("Teeth5", category: "Teeth", menu: mouthMenu)
    }

    @IBAction func onSubNose(sender: UIButton) {
        onOverlay("Nose1", category: "Nose", menu: noseMenu)
    }
    
    @IBAction func onSubNose2(sender: UIButton) {
        onOverlay("Nose2", category: "Nose", menu: noseMenu)
    }
    
    @IBAction func onSubNose3(sender: UIButton) {
        onOverlay("Nose3", category: "Nose", menu: noseMenu)
    }
    
    @IBAction func onSubNose4(sender: UIButton) {
        onOverlay("Nose4", category: "Nose", menu: noseMenu)
    }
    
    @IBAction func onSubNose5(sender: UIButton) {
        onOverlay("Nose5", category: "Nose", menu: noseMenu)
    }
}

